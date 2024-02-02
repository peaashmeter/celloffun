import 'dart:async';
import 'dart:convert';

import 'package:celloffun_frontend/game_data.dart';
import 'package:celloffun_frontend/cell.dart';
import 'package:celloffun_frontend/strategy.dart';
import 'package:flutter/material.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

class Connection {
  final WebSocketChannel channel;
  final String name;
  late final String opponentName;
  final String? sessionId;
  final StreamController<Board> boardsStreamController;
  final StreamController<int> lobbyTimerController;
  final StreamController<int> epicTimerController;
  final StreamController<int> iterationController;
  late final String _clientId;

  final Completer<GameData> _gameData = Completer();
  final Completer<bool> _simulationReady = Completer();
  final Completer<GameResult> _gameResult = Completer();
  final Completer<void> _connectionError = Completer();

  Connection({
    required this.channel,
    required this.name,
    required this.sessionId,
  })  : boardsStreamController = StreamController.broadcast(),
        lobbyTimerController = StreamController.broadcast(),
        epicTimerController = StreamController(),
        iterationController = StreamController() {
    channel.stream.listen(_handle);
    _handshake();
  }

  ready(Strategy strategy) {
    final message = {
      'status': 'ready',
      'strategy': jsonEncode(strategy.toJson())
    };
    channel.sink.add(jsonEncode(message));
  }

  Future<GameData> waitForGameData() => _gameData.future;
  Future<bool> waitForSimulation() => _simulationReady.future;
  Future<GameResult> waitForGameResult() => _gameResult.future;
  Future<void> waitForConnectionError() => _connectionError.future;

  _handle(dynamic data) => switch (jsonDecode(data)) {
        {
          'status': 'playing',
          'iterations_remain': int iterations,
          'board': List cells
        } =>
          _onBoard(cells, iterations),
        {
          'status': 'ready',
          'id': String clientId,
          'gameCode': String gameCode,
          'side': String side,
          'iterations': int iterations,
          'width': int width,
          'height': int height,
          'cells': List cells,
        } =>
          _onReady(clientId, gameCode, cells, side, iterations, width, height),
        {'lobby_countdown': int time} => lobbyTimerController.add(time),
        {'epic_countdown': int time} => epicTimerController.add(time),
        {'status': 'simulation_ready'} => _onSimulationReady(),
        {'report': Map result} => _onGameResult(result),
        {'error': 'COULD_NOT_CONNECT'} => _onError(),
        {'player': String playerId, 'opponent': String opponentName} =>
          _onOpponentInfo(playerId, opponentName),
        _ => null
      };

  _handshake() {
    final message = {'status': 'handshake', 'session': sessionId, 'name': name};
    channel.sink.add(jsonEncode(message));
  }

  _onReady(String clientId, String gameCode, List cells, String side,
      int iterations, int width, int height) {
    final side_ = switch (side) { 'top' => Sides.top, _ => Sides.bottom };
    final board_ = Board(
        width: width,
        height: height,
        cells: cells.map((cell) => Cell.fromJson(cell)).toList());
    final data = GameData(
        clientId: clientId,
        board: board_,
        side: side_,
        gameCode: gameCode,
        iterations: iterations);
    _gameData.complete(data);

    _clientId = clientId;
  }

  _onBoard(List data, int iterations) async {
    final cells = data.map((cell) => Cell.fromJson(cell)).toList();

    final board = (await _gameData.future).board;
    boardsStreamController
        .add(Board(width: board.width, height: board.height, cells: cells));
    iterationController.add(iterations);
  }

  _onOpponentInfo(String playerId, String opponentName) async {
    if (playerId != _clientId) return;
    this.opponentName = opponentName == '' ? 'Аноним' : opponentName;
    (await _gameData.future).opponentName.complete(opponentName);
  }

  _onSimulationReady() {
    _simulationReady.complete(true);
  }

  _onGameResult(Map result) {
    final playerResult = result[_clientId] as int;
    final opponentResult =
        result.entries.firstWhere((e) => e.key != _clientId).value as int;

    _gameResult.complete(
        GameResult(playerResult: playerResult, opponentResult: opponentResult));

    close();
  }

  _onError() {
    _connectionError.complete();
  }

  close() {
    lobbyTimerController.close();
    boardsStreamController.close();
    iterationController.close();
    epicTimerController.close();
  }
}

class InheritedGameData extends InheritedWidget {
  final GameData data;

  const InheritedGameData(
      {super.key, required super.child, required this.data});

  @override
  bool updateShouldNotify(InheritedGameData oldWidget) =>
      data != oldWidget.data;

  static InheritedGameData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedGameData>()!;
}

class GameResult {
  final int playerResult;
  final int opponentResult;

  GameResult({required this.playerResult, required this.opponentResult});
}
