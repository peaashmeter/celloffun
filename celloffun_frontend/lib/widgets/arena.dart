import 'package:celloffun_frontend/cell.dart';
import 'package:celloffun_frontend/connection.dart';
import 'package:celloffun_frontend/main.dart';
import 'package:celloffun_frontend/rendering.dart';
import 'package:flutter/material.dart';

class Arena extends StatelessWidget {
  const Arena({
    super.key,
    required this.connection,
  });

  final Connection connection;

  @override
  Widget build(BuildContext context) {
    connection.waitForGameResult().then((result) => showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Результат игры: '),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                title: Text('${connection.name}:',
                    style: const TextStyle(color: Colors.blue)),
                trailing: Text(
                  '${result.playerResult}',
                ),
              ),
              ListTile(
                  title: Text('${connection.opponentName}:',
                      style: const TextStyle(color: Colors.red)),
                  trailing: Text(
                    '${result.opponentResult}',
                  )),
            ]),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pushReplacement(
                      _,
                      MaterialPageRoute(
                        builder: (context) => App(
                          name: connection.name,
                        ),
                      )),
                  child: const Text('Ок'))
            ],
          ),
        ));

    final timerController = connection.epicTimerController;
    final firstBoard = connection.boardsStreamController.stream.first;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: StreamBuilder(
            stream: connection.iterationController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data.toString());
              }
              return const SizedBox.shrink();
            }),
      ),
      body: Center(
        child: FutureBuilder(
          future: firstBoard,
          builder: (context, board) {
            if (board.hasData) {
              const width = 500;
              const padding = 16;
              final sideLength =
                  MediaQuery.of(context).size.width.clamp(0, width).toDouble() -
                      padding * 2;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder(
                      stream: connection.boardsStreamController.stream,
                      builder: (context, snapshot) {
                        final playerId =
                            InheritedGameData.of(context).data.clientId;
                        var stops = (0.0, 1.0);

                        if (snapshot.hasData) {
                          final playerCells = snapshot.data!.cells
                              .where((cell) =>
                                  cell.type == CellTypes.alive &&
                                  cell.owner == playerId)
                              .length;
                          final enemyCells = snapshot.data!.cells
                              .where((cell) =>
                                  cell.type == CellTypes.alive &&
                                  cell.owner != playerId)
                              .length;
                          if ((playerCells + enemyCells) > 0) {
                            stops = (
                              playerCells / (playerCells + enemyCells),
                              enemyCells / (playerCells + enemyCells)
                            );
                          }
                        }

                        return Container(
                          height: 10,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: const [
                            Colors.blue,
                            Colors.blue,
                            Colors.red,
                            Colors.red
                          ], stops: [
                            0,
                            stops.$1,
                            stops.$1,
                            1
                          ])),
                        );
                      }),
                  const Spacer(),
                  SizedBox(
                      width: sideLength,
                      height: sideLength,
                      child: BoardPainter(connection: connection)),
                  const Spacer(),
                ],
              );
            }
            return StreamBuilder<int>(
                stream: timerController.stream,
                initialData: 3,
                builder: (context, timer) {
                  if (timer.hasData) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        key: ValueKey(timer.data.toString()),
                        timer.data.toString(),
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                });
          },
        ),
      ),
    );
  }
}

class BoardPainter extends StatelessWidget {
  const BoardPainter({
    super.key,
    required this.connection,
  });

  final Connection connection;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: connection.boardsStreamController.stream,
        builder: (context, boardSnapshot) {
          if (!boardSnapshot.hasData) return const SizedBox.shrink();

          final pixels = generatePixels(boardSnapshot.data!.cells,
              InheritedGameData.of(context).data.clientId);
          return FutureBuilder(
            future: makeGridImage(pixels),
            builder: (context, imageSnapshot) {
              if (!imageSnapshot.hasData) return const SizedBox.shrink();
              return CustomPaint(
                isComplex: true,
                painter: CustomGrid(imageSnapshot.data!),
              );
            },
          );
        });
  }
}
