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

  int secondsRemain = 150;

  final StreamController<dynamic> sessionStreamController =
      StreamController.broadcast();
  final List<Connection> connections = [];

  final Completer<void> _closed = Completer();

  Session(this.gameCode)
      : board = Board.empty(),
        totalIterations = Random().nextInt(1) + 200;

  bool checkReadiness() => (connections.every((c) => c.state is Ready));
  bool checkPlayersConnected() => connections.length == 2;

  processLobbyCountdown() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      secondsRemain -= 1;
      if (secondsRemain < 0 || isSimulating) {
        timer.cancel();
      } else {
        sessionStreamController
            .add(jsonEncode({'lobby_countdown': secondsRemain}));
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
        sessionStreamController.add(jsonEncode({'epic_countdown': countdown}));
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
    final matches = connections
        .expand((c) => (c.state as Ready).matches)
        .map((m) => m.normalize(_rivalOf(m.owner).id))
        .toList();

    var b = board;

    while (true) {
      if (b.iteration == totalIterations) {
        yield _handleOutcome(b);
        await _close();
        return;
      }

      final nextBoard = Future(() => b.iterate(matches));
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

  _handleOutcome(Board board) {
    final result = <String, int>{for (final conn in connections) conn.id: 0};

    board.cells.whereType<AliveCell>().forEach((cell) {
      result[cell.owner] = result[cell.owner]! + 1;
    });

    final report = {'report': result};
    return (jsonEncode(report));
  }

  _close() {
    _closed.complete();
  }

  sendOpponentNames() {
    for (var connection in connections) {
      final name = _rivalOf(connection.id).name;
      sessionStreamController
          .add(jsonEncode({'player': connection.id, 'opponent': name}));
    }
  }

  Connection _rivalOf(String id) {
    return connections.firstWhere((c) => c.id != id);
  }

  Future<void> waitForClose() => _closed.future;
}
