import 'package:celloffun_frontend/connection.dart';
import 'package:celloffun_frontend/widgets/arena.dart';
import 'package:celloffun_frontend/widgets/lobby.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SessionScreen extends StatefulWidget {
  final String name;
  const SessionScreen({super.key, required this.name});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late final Connection connection;

  @override
  void initState() {
    connection = Connection(
        name: widget.name,
        channel: WebSocketChannel.connect(Uri.parse('ws://localhost:8080')));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
