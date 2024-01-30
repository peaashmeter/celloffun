import 'dart:async';
import 'dart:convert';
import 'dart:core' hide Match;
import 'package:celloffun_backend/board.dart';
import 'package:celloffun_backend/cell.dart';
import 'package:celloffun_backend/connection.dart';

const _delay = 100;

class Session {
  Board? board;
  bool isSimulating = false;

  int secondsRemain = 120;

  final StreamController<dynamic> sessionStreamController =
      StreamController.broadcast();
  final List<Connection> connections = [];

  Session() : board = Board.empty();

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

    session.sessionStreamController
        .add(jsonEncode({'status': 'simulation_ready'}));

    int countdown = 3;

    Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown < 0) {
        timer.cancel();
        _simulate();
      } else {
        session.sessionStreamController
            .add(jsonEncode({'seconds': countdown - timer.tick}));
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
    return _computeBoards()
        .map((board) => board.cells.map((cell) => cell.toJson()))
        .map((cells) =>
            jsonEncode({'status': 'playing', 'board': cells.toList()}))
        .map((data) => data as dynamic)
        .pipe(sessionStreamController);
  } //websocket хочет dynamic

  Future<String> getGameData(String id) async => jsonEncode({
        'status': 'ready',
        'id': id,
        'side': 'bottom',
        'width': Board.width,
        'height': Board.height,
        'cells': board?.cells,
      });

  Stream<Board> _computeBoards() async* {
    assert(board != null);
    while (true) {
      if (board?.iteration == 100) {
        _handleOutcome();
        return;
      }

      final nextBoard = Future(() => board!.iterate(
          connections.expand((c) => (c.state as Ready).matches).toList()));
      final result = await Future.wait(
          [nextBoard, Future.delayed(Duration(milliseconds: _delay))]);
      yield result.first as Board;

      _computeBoards();
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
    sessionStreamController.add(jsonEncode(report));
    sessionStreamController.close();
  }
}
