import 'package:celloffun_frontend/connection.dart';
import 'package:celloffun_frontend/main.dart';
import 'package:celloffun_frontend/widgets/arena.dart';
import 'package:celloffun_frontend/widgets/lobby.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SessionScreen extends StatefulWidget {
  final String? sessionId;
  final String name;
  const SessionScreen({super.key, required this.name, this.sessionId});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late final Connection connection;
  late final Lobby lobby;

  @override
  void initState() {
    const endpoint = bool.hasEnvironment('ENDPOINT')
        ? String.fromEnvironment('ENDPOINT')
        : 'ws://localhost:8080';

    connection = Connection(
        sessionId: widget.sessionId,
        name: widget.name,
        channel: WebSocketChannel.connect(Uri.parse(endpoint)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    connection.waitForConnectionError().then((_) {
      connection.close();
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ошибка!'),
          content: const Text('Невозможно подключиться к игре.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const App(),
                    )),
                child: const Text('Ок'))
          ],
        ),
      );
    });

    return FutureBuilder(
        future: connection.waitForGameData(),
        builder: (context, gameDataSnapshot) {
          if (!gameDataSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return InheritedGameData(
              data: gameDataSnapshot.data!,
              child: FutureBuilder(
                future: connection.waitForSimulation(),
                builder: (context, simulationReadySnapshot) {
                  if (simulationReadySnapshot.hasData) {
                    return Arena(connection: connection);
                  }
                  return Lobby(
                    connection: connection,
                    board: gameDataSnapshot.data!.board,
                  );
                },
              ));
        });
  }
}
