import 'dart:async';
import 'dart:convert';
import 'dart:core' hide Match;
import 'dart:math';
import 'package:celloffun_backend/board.dart';
import 'package:celloffun_backend/cell.dart';
import 'package:celloffun_backend/connection.dart';

const _delay = 100;

class Session {
  final int totalIterations;
  final String gameCode;
  Board? board;
  bool isSimulating = false;

  int secondsRemain = 120;

  final StreamController<dynamic> sessionStreamController =
      StreamController.broadcast();
  final List<Connection> connections = [];

  Session(this.gameCode)
      : board = Board.empty(),
        totalIterations = Random().nextInt(300) + 200;

  bool checkReadiness() => (connections.every((c) => c.state is Ready));
  bool checkPlayersConnected() => connections.length == 1;

  processLobbyCountdown() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      secondsRemain -= 1;
      if (secondsRemain < 0 || isSimulating) {
        timer.cancel();
      } else {
        sessionStreamController.add(jsonEncode({'seconds': secondsRemain}));
      }
    });
  }

  startSimulation() {
    isSimulating = true;

    sessionStreamController.add(jsonEncode({'status': 'simulation_ready'}));

    int countdown = 3;

    Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown < 0) {
        timer.cancel();
        _simulate();
      } else {
        sessionStreamController.add(jsonEncode({'seconds': countdown}));
        countdown -= 1;
      }
    });
  }

  _simulate() {
    for (final connection in connections) {
      for (var point in (connection.state as Ready).points) {
        board!.cells[point] = AliveCell(owner: connection.id);
      }
    }
    return _computeBoards(board!).pipe(sessionStreamController);
  } //websocket хочет dynamic

  Future<String> getGameData(String id) async => jsonEncode({
        'status': 'ready',
        'id': id,
        'gameCode': gameCode,
        'side': connections.isEmpty ? 'bottom' : 'top',
        'iterations': totalIterations,
        'width': Board.width,
        'height': Board.height,
        'cells': board?.cells,
      });

  Stream<dynamic> _computeBoards(Board board) async* {
    var b = board;

    while (true) {
      if (b.iteration == totalIterations) {
        yield _handleOutcome();
        return;
      }

      final nextBoard = Future(() => b.iterate(
          connections.expand((c) => (c.state as Ready).matches).toList()));
      final result = await Future.wait(
          [nextBoard, Future.delayed(Duration(milliseconds: _delay))]);

      b = result.first as Board;
      yield jsonEncode({
        'status': 'playing',
        'iterations_remain': totalIterations - b.iteration,
        'board': b.cells.map((cell) => cell.toJson()).toList()
      });
    }
  }

  _handleOutcome() {
    final result = <String, int>{};
    board!.cells.whereType<AliveCell>().forEach((cell) {
      if (result.containsKey(cell.owner)) {
        result[cell.owner] = result[cell.owner]! + 1;
      }
      result[cell.owner] = 1;
    });

    final report = {'report': result};
    return (jsonEncode(report));
  }
}
