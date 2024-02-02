import 'dart:async';
import 'dart:core' hide Match;
import 'package:celloffun_frontend/cell.dart';
import 'package:celloffun_frontend/connection.dart';
import 'package:celloffun_frontend/game_data.dart';
import 'package:celloffun_frontend/strategy.dart';
import 'package:celloffun_frontend/widgets/cell_picker.dart';
import 'package:celloffun_frontend/widgets/cell_widget.dart';
import 'package:celloffun_frontend/widgets/pattern_picker.dart';
import 'package:flutter/material.dart';

class InheritedLobby extends InheritedNotifier {
  final LobbyData data;
  const InheritedLobby({super.key, required this.data, required super.child})
      : super(notifier: data);

  @override
  bool updateShouldNotify(covariant InheritedLobby oldWidget) => true;

  static InheritedLobby of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedLobby>()!;
}

class LobbyData extends ChangeNotifier {
  late Cell selectedCell;
  late List<Match> matches;
  Set<int> startIndices = {};

  bool ready = false;
  bool showFullData = true;

  LobbyData({
    required this.selectedCell,
    required this.matches,
    required this.ready,
  });

  void selectCell(Cell cell) {
    selectedCell = cell;
    notifyListeners();
  }

  void setPatternCell(Cell cell, int patternIndex, int cellIndex) {
    matches[patternIndex].pattern.cells[cellIndex] = cell;
    notifyListeners();
  }

  void setMatchResult(Cell cell, int matchIndex) {
    matches[matchIndex].result = cell;
    notifyListeners();
  }

  void addStartIndex(int index) {
    startIndices.add(index);
  }

  void removeStartIndex(int index) {
    startIndices.remove(index);
  }

  void toogleDisplay(bool show) {
    showFullData = show;
    notifyListeners();
  }
}

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
    matches = List.generate(
        6,
        (_) => Match(
            pattern: Pattern(
                cells: List<Cell>.generate(
              9,
              (index) => index == 4
                  ? Cell(CellTypes.alive, owner: clientId)
                  : Cell(CellTypes.dead, owner: clientId),
            )),
            result: Cell(CellTypes.alive, owner: clientId)));

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
              MatchPicker(),
              CellPalette()
            ],
          ),
        );
      }),
    );
  }
}

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
              children: lobbyData.showFullData
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

class LobbyTools extends StatelessWidget {
  const LobbyTools({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final data = InheritedLobby.of(context).data;
    return Column(
      children: [
        CheckboxListTile(
            title: const Text('Подробная информация'),
            value: data.showFullData,
            onChanged: (value) => data.toogleDisplay(value ?? false))
      ],
    );
  }
}

class CellPalette extends StatelessWidget {
  const CellPalette({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final clientId = InheritedGameData.of(context).data.clientId;

    return SizedBox(
      height: 60,
      child: Material(
        elevation: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            PaletteCell(
              cell: Cell(CellTypes.alive, owner: clientId),
            ),
            PaletteCell(
              cell: Cell(CellTypes.dead, owner: clientId),
            ),
            PaletteCell(
              cell: Cell(CellTypes.void_, owner: clientId),
            ),
            const PaletteCell(
              cell: Cell(CellTypes.alive, owner: 'enemy'),
            ),
          ],
        ),
      ),
    );
  }
}

class PaletteCell extends StatelessWidget {
  final Cell cell;
  const PaletteCell({
    super.key,
    required this.cell,
  });

  @override
  Widget build(BuildContext context) {
    final data = InheritedLobby.of(context).data;
    final selectedCell = data.selectedCell;
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
              width: 2,
              color: selectedCell == cell
                  ? Colors.green
                  : Theme.of(context).colorScheme.secondary)),
      child: CellWidget(
        onTap: () {
          data.selectCell(cell);
        },
        clientId: InheritedGameData.of(context).data.clientId,
        cell: cell,
      ),
    );
  }
}
