abstract class Setup {}

class ClientSetup extends Setup {
  final Setup child;

  ClientSetup({required this.child});

  // Перестраивает дерево с конфигурацией
  void setState() {}

  Future<T> request<T>(String key, {JSON? body, JSON? headers}) async {
    return null as T;
  }

  void send(String key, {Object? event}) {}
}

class Route extends Setup {
  final Setup child;
  final String url;

  Route({required this.child, required this.url});
}

class Requests extends Setup {
  final List<Setup> children;

  Requests({required this.children});
}

class Request<T> extends Setup {
  final ResponseCallback<T>? onResponse;
  final ResponseCallback<T>? on200;
  final ResponseCallback<T>? on300;
  final ResponseCallback<T>? on400;
  final ResponseCallback<T>? on500;
  final ResponseCallback<T>? onError;

  final String key;
  final String? url;
  final JSON? headers;

  Request.get({
    required this.key,
    this.onResponse,
    this.on200,
    this.on300,
    this.on400,
    this.on500,
    this.onError,
    this.url,
    this.headers,
  });

  Request.put({
    required this.key,
    this.onResponse,
    this.on200,
    this.on300,
    this.on400,
    this.on500,
    this.onError,
    this.url,
    this.headers,
  });
}

class Interceptor extends Setup {
  final Setup child;
  final ResponseCallback? interceptor;
  final ResponseCallback? onResponse;
  final ResponseCallback? on200;
  final ResponseCallback? on300;
  final ResponseCallback? on400;
  final ResponseCallback? on500;
  final ResponseCallback? onError;

  Interceptor({
    required this.child,
    this.interceptor,
    this.onResponse,
    this.on200,
    this.on300,
    this.on400,
    this.on500,
    this.onError,
  });
}

class WebSocket extends Setup {
  final String key;
  final String? url;
  final String? whereKey;
  final Function? onClose;
  final List<WSListener> listeners;

  WebSocket({required this.key, this.url, this.whereKey, this.onClose, required this.listeners});
}

class WSListener {
  final String? whereKey;
  final String? isEqual;
  final ResponseCallback listen;

  WSListener({
    required this.listen,
    this.whereKey,
    this.isEqual,
  });
}

typedef ResponseCallback<T> = T Function(dynamic);
typedef JSON = Map<String, dynamic>;
