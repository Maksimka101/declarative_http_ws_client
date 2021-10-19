import 'package:declarative_api/client.dart';

void main() async {
  var serverRepository = ServerRepository();
  serverRepository.init();
  await serverRepository.ping();
  var user = await serverRepository.authUser('pass', 'name');
}

class ServerRepository {
  var serverIsFine = false;
  var _userAuthorized = false;
  late final ClientSetup _client;

  void init() {
    // Декларируем http/ws клиент
    _client = ClientSetup(
      child: Route(
        // Устанавливаем host по умолчанию с помощью виджета [Route], который добавляет к адресам дочерних виджетов [url]
        url: 'some.host',
        child: Requests(
          children: [
            Request.get(
              // Ключ по которому будет вызван этот запрос
              key: 'ping',
              // Optional
              url: '/ping',
              headers: {'jwt': 'token'},
              // Вызывается при любом ответе с сервера, если не произошло ошибки
              onResponse: (resp) {},
              // Вызывается при ошибке. Типа try/catch
              onError: (err) {},
              // Вызывается при ответе сервера с кодом 2ХХ. Эта функция может преобразовать ответ сервера в модель
              on200: (resp200) {},
              on300: (resp300) {},
              on400: (resp400) {},
            ),
            Interceptor(
              // Вызывается при выполнении дочерних запросов
              interceptor: (requestInfo) {},
              on400: (resp400) {},
              on500: (resp500) {
                print('Failed to authorize user');
                return null;
              },
              // Делает запрос по ссылке `http://some.host/authorize` и мапит результат в [User], если сервер не выдал ошибку
              child: Request<User>.put(
                key: 'auth',
                url: '/authorize',
                on200: (resp200) {
                  _userAuthorized = true;
                  // Обновляет конфигурацию клиента. После этого должен добавится [WSListener] для ивента `logout`
                  _client.setState();
                  return User.fromJson(resp200.body);
                },
              ),
            ),
            // Web socket соединение, которое устанавливается при первом вызове `client.send("chat")`
            WebSocket(
              key: 'chat',
              // Указывается поле в json-е с сервера, по которому определяется, какой [WSListener] должен сработать
              whereKey: 'eventType',
              onClose: (code) {},
              // Listen for events from server
              listeners: [
                // Этот Listener отработает, если с сервера придет такой json `{"eventType": "pingFromServer"}`
                WSListener(
                  // Или можно установить это поле для каждого [WSListener]-а отдельно
                  whereKey: 'eventType',
                  isEqual: 'pingFromServer',
                  listen: (event) => serverIsFine = true,
                ),
                if (serverIsFine && _userAuthorized)
                  WSListener(
                    isEqual: 'logout',
                    listen: (event) => _userAuthorized = false,
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    _client.send('chat');
  }

  /// Конвертируем реактивный запрос в императивный
  ///
  /// При этом можно реагировать и только реактивно в [Request.on200]
  Future<User?> authUser(String password, String name) async {
    final user = await _client.request<User?>(
      'auth',
      // Тело запроса здесь, так как виджет [Request] отвечает за конфигурацию и обработку ответа на запрос
      // А здесь находятся входные данные для запроса, которые невозможно иметь при конфигурации
      body: {'name': name, 'password': password},
      headers: {},
    );
    return user;
  }

  Future<void> ping() {
    return _client.request('ping');
  }
}

class User {
  final String name;

  User(this.name);

  User.fromJson(JSON json) : name = json['name'];
}
