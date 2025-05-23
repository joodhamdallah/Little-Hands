import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  late IO.Socket _socket;
  bool _isConnected = false;
  bool _listenerRegistered = false;

  SocketService._internal();

void connect(String userId) {
  if (_isConnected) {
    print('⚠️ Already connected, forcing reconnection...');
    _socket.disconnect(); // 🔁
  }

  _socket = IO.io('http://10.0.2.2:3000', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': true,
    'forceNew': true, // 🔥 force new socket every time
  });

  _socket.onConnect((_) {
    print('✅ Connected to socket');
    _isConnected = true;
    _socket.emit('join', userId); 
  });

  _socket.onDisconnect((_) {
    print('❌ Disconnected from socket');
    _isConnected = false;
  });
}


  void onNewNotification(Function(Map<String, dynamic>) callback) {
    _socket.off('newNotification'); // 👈 always clear old listener
    _socket.on('newNotification', (data) {
      print('🔔 New notification: $data');
      callback(Map<String, dynamic>.from(data));
    });
    _listenerRegistered = true;
  }

  void disconnect() {
    _socket.disconnect();
    _isConnected = false;
    _listenerRegistered = false;
  }

  void removeListeners() {
    _socket.off('newNotification');
  }
}
