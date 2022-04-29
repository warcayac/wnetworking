part of wnetworking;


abstract class _ISocketClass<T> {
  T? _socket;
  final String server;
  var socketInit = false;
  /* ---------------------------------------------------------------------------- */
  _ISocketClass(this.server);
  /* ---------------------------------------------------------------------------- */
  Future<bool> initSocket(Function statusDisplayer, Function echoListener) async {
    try {
      print('Connecting to socket');
      _socket = await _getConnSocket();
      statusDisplayer(true);
      _listen(echoListener);
      socketInit = true;
      return true;
    } catch (e) {
      print(e);
      statusDisplayer(false);
      return false;
    }
  }
  /* ---------------------------------------------------------------------------- */
  Future<bool> sendMessage(String message) async {
    try {
      _add(message);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
  /* ---------------------------------------------------------------------------- */
  void closeSocket() {
    _close();
    _socket = null;
  }
  /* ---------------------------------------------------------------------------- */
  Future<T> _getConnSocket();
  Future _close();
  StreamSubscription _listen(Function echoListener);
  void _add(String message);
}

/* ============================================================================================= */

class SocketService extends _ISocketClass<Socket> {
  @override
  Socket? _socket;
  final int port;
  /* ---------------------------------------------------------------------------- */
  // Default ports:: HTTP: 80, HTTPS: 443
  SocketService(String server, {this.port = 443}) : super(server);
  /* ---------------------------------------------------------------------------- */
  @override
  Future<Socket> _getConnSocket() => Socket.connect(server, port);
  /* ---------------------------------------------------------------------------- */
  void cleanUp() {
    if (_socket != null) {
      _socket!.destroy();
    }
  }
  /* ---------------------------------------------------------------------------- */
  @override
  Future _close() => _socket!.close();
  /* ---------------------------------------------------------------------------- */
  @override
  StreamSubscription _listen(Function echoListener) => 
    _socket!.listen((event) => echoListener(utf8.decode(event)));
  /* ---------------------------------------------------------------------------- */
  @override
  void _add(String message) => _socket!.add(utf8.encode(message));
}

/* ============================================================================================= */

class WebSocketService extends _ISocketClass<WebSocket> {
  @override
  WebSocket? _socket;
  /* ---------------------------------------------------------------------------- */
  WebSocketService(String server) : super(server);
  /* ---------------------------------------------------------------------------- */
  @override
  Future<WebSocket> _getConnSocket() => WebSocket.connect(server);
  /* ---------------------------------------------------------------------------- */
  @override
  Future _close() => _socket!.close();
  /* ---------------------------------------------------------------------------- */
  @override
  StreamSubscription _listen(Function echoListener) => 
    _socket!.listen((event) => echoListener(utf8.decode(event)));
  /* ---------------------------------------------------------------------------- */
  @override
  void _add(String message) => _socket!.add(utf8.encode(message));
}
