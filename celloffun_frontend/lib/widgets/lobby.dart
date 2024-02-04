import 'dart:async';
import 'dart:core' hide Match;
import 'package:celloffun_frontend/cell.dart';
import 'package:celloffun_frontend/connection.dart';
import 'package:celloffun_frontend/game_data.dart';
import 'package:celloffun_frontend/strategy.dart';
import 'package:celloffun_frontend/widgets/cell_picker.dart';
import 'package:celloffun_frontend/widgets/pattern_picker.dart';
import 'package:flutter/material.dart';

import '../inherited_lobby.dart';
import '../lobby_data.dart';
import 'cell_palette.dart';
import 'lobby_info.dart';
import 'lobby_tools.dart';

class Lobby extends StatefulWidget {
  final Connection connection;
  final Board board;
  const Lobby({super.key, required this.connection, required this.board});

  @override
  State<Lobby> createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  StreamSubscription? timeoutSubscription;
  late String clientId;
  late Cell selectedCell;
  late List<Match> matches;
  bool ready = false;

  @override
  void didChangeDependencies() {
    clientId = InheritedGameData.of(context).data.clientId;
    selectedCell = Cell(CellTypes.alive, owner: clientId);
    matches = List.generate(5, (index) => Match.plain(clientId));

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return InheritedLobby(
      data: LobbyData(
        selectedCell: selectedCell,
        matches: matches,
        ready: ready,
      ),
      child: Builder(builder: (context) {
        timeoutSubscription ??=
            widget.connection.lobbyTimerController.stream.listen(
          (timeRemains) {
            if (ready) {
              timeoutSubscription?.cancel();
              return;
            }

            if (timeRemains == 0) {
              timeoutSubscription?.cancel();
              if (!mounted) return;
              final data = InheritedLobby.of(context).data;
              widget.connection
                  .ready(Strategy(data.matches, data.startIndices.toList()));
              setState(() {
                ready = true;
              });
            }
          },
        );

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            title: StreamBuilder(
                stream: widget.connection.lobbyTimerController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data.toString());
                  }
                  return const Icon(Icons.timer_outlined);
                }),
            actions: [
              Builder(builder: (context) {
                return IconButton(
                    onPressed: () {
                      if (!ready) {
                        timeoutSubscription?.cancel();

                        final data = InheritedLobby.of(context).data;
                        widget.connection.ready(
                            Strategy(data.matches, data.startIndices.toList()));
                        setState(() {
                          ready = true;
                        });
                      }
                    },
                    icon: Tooltip(
                      message: 'Готовность',
                      child: Icon(
                        Icons.check_circle_outline_rounded,
                        color: ready ? Colors.green : null,
                      ),
                    ));
              })
            ],
            centerTitle: true,
          ),
          body: const Column(
            children: [
              LobbyInfo(),
              LobbyTools(),
              CellPicker(),
              PatternPicker(),
              CellPalette()
            ],
          ),
        );
      }),
    );
  }
}
