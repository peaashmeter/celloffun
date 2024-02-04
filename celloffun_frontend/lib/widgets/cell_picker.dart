import 'package:celloffun_frontend/cell.dart';
import 'package:celloffun_frontend/connection.dart';
import 'package:celloffun_frontend/game_data.dart';
import 'package:celloffun_frontend/rendering.dart';
import 'package:flutter/material.dart';

import '../inherited_lobby.dart';

const maxInitialCells = 10;

class CellPicker extends StatefulWidget {
  const CellPicker({super.key});

  @override
  State<CellPicker> createState() => CellPickerState();
}

class CellPickerState extends State<CellPicker> {
  late List<Cell> cells;
  late int ownCellsCount;
  late Set<int> availablePositions;

  @override
  void didChangeDependencies() {
    final gameData = InheritedGameData.of(context).data;
    cells = gameData.board.cells;

    availablePositions = switch (gameData.side) {
      Sides.bottom => List.generate(
                gameData.board.height * gameData.board.width, (index) => index)
            .where((index) {
          int x = index % gameData.board.width;
          int y = index ~/ gameData.board.height;

          return y >= gameData.board.height - 25 &&
              x > 25 &&
              x < gameData.board.width - 25;
        }),
      _ => List.generate(
                gameData.board.height * gameData.board.width, (index) => index)
            .where((index) {
          int x = index % gameData.board.width;
          int y = index ~/ gameData.board.height;

          return y < 25 && x > 25 && x < gameData.board.width - 25;
        })
    }
        .toSet();
    super.didChangeDependencies();
  }

  _onCellUpdateRequest(int index) {
    final cell = cells[index];
    if (!availablePositions.contains(index)) return;

    final id = InheritedGameData.of(context).data.clientId;
    ownCellsCount =
        cells.where((c) => c.type == CellTypes.alive && c.owner == id).length;

    if (cell.type == CellTypes.alive) {
      final c = Cell(CellTypes.dead,
          owner: InheritedGameData.of(context).data.clientId);

      InheritedLobby.of(context).data.removeStartIndex(index);

      setState(() {
        cells[index] = c;
      });
    } else if (cell.type == CellTypes.dead && ownCellsCount < maxInitialCells) {
      final c = Cell(CellTypes.alive,
          owner: InheritedGameData.of(context).data.clientId);

      InheritedLobby.of(context).data.addStartIndex(index);

      setState(() {
        cells[index] = c;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = InheritedLobby.of(context).data.showPatterns ? 300 : 500;

    const padding = 16;
    final sideLength =
        MediaQuery.of(context).size.width.clamp(0, width).toDouble() -
            padding * 2;
    final gameData = InheritedGameData.of(context).data;

    final pixels =
        generatePixels(cells, gameData.clientId, highlight: availablePositions);

    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 10,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
              child: SizedBox(
                width: sideLength,
                height: sideLength,
                child: ClipRect(
                  child: GestureDetector(
                    onTapDown: (details) {
                      final index = _calculateCellIndex(
                          sideLength, details.localPosition);
                      _onCellUpdateRequest(index);
                    },
                    child: GridPaper(
                      interval: sideLength / 4,
                      divisions: 1,
                      subdivisions: 25,
                      child: FutureBuilder(
                        future: makeGridImage(pixels),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox.shrink();
                          return CustomPaint(
                            painter: CustomGrid(snapshot.data!),
                            size: Size(sideLength, sideLength),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _calculateCellIndex(double side, Offset tapPosition) {
    final board = InheritedGameData.of(context).data.board;

    final cellSize = side / board.width;
    final x = tapPosition.dx ~/ cellSize;
    final y = tapPosition.dy ~/ cellSize;

    return y * board.height + x;
  }
}
