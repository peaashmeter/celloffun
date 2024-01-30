import 'package:celloffun_frontend/cell.dart';
import 'package:celloffun_frontend/connection.dart';
import 'package:celloffun_frontend/widgets/cell_widget.dart';
import 'package:celloffun_frontend/widgets/lobby.dart';
import 'package:flutter/material.dart';

class MatchPicker extends StatelessWidget {
  const MatchPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1.5, crossAxisCount: 2),
          itemBuilder: (context, index) => MatchCard(
            key: ValueKey(index),
            userId: InheritedGameData.of(context).data.clientId,
            index: index,
            lobbyData: InheritedLobby.of(context).data,
          ),
          itemCount: InheritedLobby.of(context).data.matches.length,
        ),
      ),
    );
  }
}

class MatchCard extends StatelessWidget {
  final String userId;
  final int index;
  final LobbyData lobbyData;
  const MatchCard(
      {super.key,
      required this.index,
      required this.userId,
      required this.lobbyData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          Material(
            child: Row(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.secondary)),
                  width: 100,
                  height: 100,
                  child: GridView.count(
                    crossAxisCount: 3,
                    children: List.generate(
                        9,
                        (cellIdx) => PatternCell(
                              patternIdx: index,
                              cellIdx: cellIdx,
                              userId: userId,
                              lobbyData: lobbyData,
                            )),
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_right_alt_rounded,
                size: 48,
              ),
              Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.secondary)),
                  child: PatternResultCell(
                    userId: userId,
                    patternIdx: index,
                    lobbyData: lobbyData,
                  ))
            ]),
          ),
          const Divider()
        ],
      ),
    );
  }
}

class PatternCell extends StatelessWidget {
  final int patternIdx;
  final int cellIdx;
  final String userId;
  final LobbyData lobbyData;

  const PatternCell({
    super.key,
    required this.userId,
    required this.patternIdx,
    required this.cellIdx,
    required this.lobbyData,
  });

  @override
  Widget build(BuildContext context) {
    final patternCells = lobbyData.matches[patternIdx].pattern.cells;
    final cell = patternCells[cellIdx]!;
    return CellWidget(
      clientId: userId,
      cell: cell,
      onTap: () {
        final selectedCell = lobbyData.selectedCell;

        if (cell == Cell(CellTypes.alive, owner: userId) &&
            patternCells
                    .where((c) => c == Cell(CellTypes.alive, owner: userId))
                    .length ==
                1) {
          return;
        }

        return lobbyData.setPatternCell(selectedCell, patternIdx, cellIdx);
      },
    );
  }
}

class PatternResultCell extends StatelessWidget {
  final int patternIdx;
  final String userId;
  final LobbyData lobbyData;

  const PatternResultCell({
    super.key,
    required this.userId,
    required this.patternIdx,
    required this.lobbyData,
  });

  @override
  Widget build(BuildContext context) {
    final cell = lobbyData.matches[patternIdx].result;
    return CellWidget(
      clientId: userId,
      cell: cell,
      onTap: () {
        final selectedCell = lobbyData.selectedCell;
        lobbyData.setMatchResult(selectedCell, patternIdx);
      },
    );
  }
}
