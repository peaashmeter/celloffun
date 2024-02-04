import 'package:celloffun_frontend/cell.dart';
import 'package:celloffun_frontend/connection.dart';
import 'package:celloffun_frontend/widgets/cell_widget.dart';
import 'package:flutter/material.dart';

import '../inherited_lobby.dart';
import '../lobby_data.dart';

class PatternPicker extends StatelessWidget {
  const PatternPicker({super.key});

  @override
  Widget build(BuildContext context) {
    if (!InheritedLobby.of(context).data.showPatterns) {
      return const SizedBox.shrink();
    }
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1.5, crossAxisCount: 2),
          itemBuilder: (context, index) =>
              switch (index == InheritedLobby.of(context).data.matches.length) {
            true => const _AddMatchButton(),
            _ => MatchCard(
                key: ValueKey(index),
                userId: InheritedGameData.of(context).data.clientId,
                index: index,
                lobbyData: InheritedLobby.of(context).data,
              ),
          },
          itemCount: InheritedLobby.of(context).data.matches.length + 1,
        ),
      ),
    );
  }
}

class _AddMatchButton extends StatefulWidget {
  const _AddMatchButton();

  @override
  State<_AddMatchButton> createState() => _AddMatchButtonState();
}

class _AddMatchButtonState extends State<_AddMatchButton> {
  var opacity = 0.0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        opacity = 1;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      curve: Curves.easeIn,
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
                width: 2, color: Theme.of(context).colorScheme.secondary),
          ),
          child: InkWell(
            onTap: () {
              InheritedLobby.of(context)
                  .data
                  .addMatch(InheritedGameData.of(context).data.clientId);
            },
            child: const Center(
              child: Icon(Icons.add_rounded),
            ),
          ),
        ),
      ),
    );
  }
}

class MatchCard extends StatefulWidget {
  final String userId;
  final int index;
  final LobbyData lobbyData;
  const MatchCard(
      {super.key,
      required this.index,
      required this.userId,
      required this.lobbyData});

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  var opacity = 0.0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        opacity = 1;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      curve: Curves.easeIn,
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
                width: 2, color: Theme.of(context).colorScheme.secondary),
          ),
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
                            key: ValueKey(widget.index * 10 + cellIdx),
                            patternIdx: widget.index,
                            cellIdx: cellIdx,
                            userId: widget.userId,
                            lobbyData: widget.lobbyData,
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
                  userId: widget.userId,
                  patternIdx: widget.index,
                  lobbyData: widget.lobbyData,
                ))
          ]),
        ),
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
