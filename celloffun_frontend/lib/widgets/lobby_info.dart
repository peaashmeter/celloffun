import 'package:celloffun_frontend/connection.dart';
import 'package:flutter/material.dart';

import '../inherited_lobby.dart';

class LobbyInfo extends StatelessWidget {
  const LobbyInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final gameData = InheritedGameData.of(context).data;
    final lobbyData = InheritedLobby.of(context).data;

    return AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: SelectionArea(
          child: Column(
              children: !lobbyData.showPatterns
                  ? [
                      ListTile(
                        title: const Text('Код игры:'),
                        trailing: Text(gameData.gameCode),
                      ),
                      FutureBuilder<String>(
                        future: gameData.opponentName.future,
                        builder: (context, snapshot) => ListTile(
                            title: const Text('Имя оппонента:'),
                            trailing: !snapshot.hasData
                                ? const SizedBox(
                                    width: 100,
                                    child: LinearProgressIndicator(),
                                  )
                                : Text(snapshot.data!)),
                      ),
                      ListTile(
                          title: const Text('Количество итераций:'),
                          trailing: Text(gameData.iterations.toString())),
                      const ListTile(
                        title: Text(
                            'Размести до 10 стартовых синих клеток на игровом поле. Затем настрой правила для своих клеток.\nПодсказка: поле можно приближать!'),
                      ),
                    ]
                  : const []),
        ));
  }
}
