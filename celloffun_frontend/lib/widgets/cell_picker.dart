import 'package:celloffun_frontend/cell.dart';
import 'package:celloffun_frontend/connection.dart';
import 'package:celloffun_frontend/game_data.dart';
import 'package:celloffun_frontend/rendering.dart';
import 'package:celloffun_frontend/widgets/lobby.dart';
import 'package:flutter/material.dart';

const maxInitialCells = 10;

class CellPicker extends StatefulWidget {
  final Board board;
  const CellPicker({super.key, required this.board});

  @override
  State<CellPicker> createState() => CellPickerState();
}

class CellPickerState extends State<CellPicker> {
  late final List<Cell> cells;
  late int ownCellsCount;
  late Set<int> availablePositions;

  @override
  void initState() {
    cells = List.from(widget.board.cells);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    final id = InheritedGameData.of(context).data.clientId;
    ownCellsCount = cells.where((cell) => cell.owner == id).length;

    final gameData = InheritedGameData.of(context).data;
    availablePositions = switch (gameData.side) {
      Sides.bottom => List.generate(
                widget.board.height * widget.board.width, (index) => index)
            .where((index) {
          int x = index % widget.board.width;
          int y = index ~/ widget.board.height;

          return y >= widget.board.height - 25 &&
              x > 25 &&
              x < widget.board.width - 25;
        }),
      _ => List.generate(
                widget.board.height * widget.board.width, (index) => index)
            .where((index) {
          int x = index % widget.board.width;
          int y = index ~/ widget.board.height;

          return y < 25 && x > 25 && x < widget.board.width - 25;
        })
    }
        .toSet();
    super.didChangeDependencies();
  }

  _onCellUpdateRequest(int index) {
    final cell = cells[index];
    if (!availablePositions.contains(index)) return;

    if (cell.type == CellTypes.alive) {
      ownCellsCount -= 1;
      final c = Cell(CellTypes.dead,
          owner: InheritedGameData.of(context).data.clientId);

      InheritedLobby.of(context).data.removeStartIndex(index);

      setState(() {
        cells[index] = c;
      });
    }
    if (cell.type == CellTypes.dead && ownCellsCount < maxInitialCells) {
      ownCellsCount += 1;
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
    const padding = 16;
    final sideLength =
        MediaQuery.of(context).size.width.clamp(0, 500).toDouble() -
            padding * 2;
    final gameData = InheritedGameData.of(context).data;

    final pixels =
        generatePixels(cells, gameData.clientId, highlight: availablePositions);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: SizedBox(
            width: sideLength,
            height: sideLength,
            child: ClipRect(
              child: GestureDetector(
                onTapDown: (details) {
                  final index =
                      _calculateCellIndex(sideLength, details.localPosition);
                  _onCellUpdateRequest(index);
                },
                child: GridPaper(
                  interval: sideLength / 4,
                  divisions: 1,
                  subdivisions: 25,
                  child: FutureBuilder(
                    future: makeGridImage(pixels),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Placeholder();
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
    );
  }

  int _calculateCellIndex(double side, Offset tapPosition) {
    final cellSize = side / widget.board.width;
    final x = tapPosition.dx ~/ cellSize;
    final y = tapPosition.dy ~/ cellSize;

    return y * widget.board.height + x;
  }
}
