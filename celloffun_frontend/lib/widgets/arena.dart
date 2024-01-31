import 'package:celloffun_frontend/connection.dart';
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
    final timerController = connection.timerController;
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
              })),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder(
              future: firstBoard,
              builder: (context, board) {
                if (board.hasData) {
                  const width = 500;
                  const padding = 16;
                  final sideLength = MediaQuery.of(context)
                          .size
                          .width
                          .clamp(0, width)
                          .toDouble() -
                      padding * 2;
                  return SizedBox(
                      width: sideLength,
                      height: sideLength,
                      child: BoardPainter(connection: connection));
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
          ],
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
