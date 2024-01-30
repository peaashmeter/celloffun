import 'package:celloffun_backend/connection.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:web_socket_channel/web_socket_channel.dart';

void main(List<String> arguments) {
  final handler = webSocketHandler((WebSocketChannel webSocket) async {
    await webSocket.ready;

    Connection(webSocket).handle();
  });

  shelf_io.serve(handler, 'localhost', 8080).then((server) {
    print('Serving at ws://${server.address.host}:${server.port}');
  });
}
