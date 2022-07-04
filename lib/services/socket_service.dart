import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus {
  Online,
  Offline,
  Connecting
}

class SocketService with ChangeNotifier{

  late ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket;

  ServerStatus get serverStatus => _serverStatus;
  IO.Socket get socket => _socket;

  Function get emit => _socket.emit;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {

    _socket = IO.io('http://192.168.0.25:5000/', {
      'transports': ['websocket'],
      'autoConnect':true
    });

    _socket.onConnect((_) {
      print('connect');
      _serverStatus = ServerStatus.Online;
      notifyListeners();
      // socket.emit('msg', 'test');
    });

    _socket.onDisconnect((_) {
      print('disconnect');
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    socket.on('nuevo-mensaje', ( payload ) {
      print('nuevo-mensaje: ');
      print('nombre: ' + payload['nombre']);
      print('mensaje  : ' + payload['mensaje']);
    });

    // socket.off('nuevo-mensaje');
  }

}