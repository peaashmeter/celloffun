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
  final StreamController<Board> boardsStreamController;
  final StreamController<int> timerController;
  String? id;

  final Completer<GameData> _gameData = Completer();
  final Completer<bool> _simulationReady = Completer();

  Connection({required this.channel, required this.name})
      : boardsStreamController = StreamController(),
        timerController = StreamController() {
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

  _handle(dynamic data) => switch (jsonDecode(data)) {
        {'status': 'playing', 'board': List cells} => _onBoard(cells),
        {
          'status': 'ready',
          'id': String id,
          'side': String side,
          'width': int width,
          'height': int height,
          'cells': List cells,
        } =>
          _onReady(id, cells, side, width, height),
        {'seconds': int time} => timerController.add(time),
        {'status': 'simulation_ready'} => _onSimulationReady(),
        _ => null
      };

  _handshake() {
    final message = {'status': 'handshake', 'name': name};
    channel.sink.add(jsonEncode(message));
  }

  _onReady(String id, List cells, String side, int width, int height) {
    final side_ = switch (side) { 'top' => Sides.top, _ => Sides.bottom };
    final board_ = Board(
        width: width,
        height: height,
        cells: cells.map((cell) => Cell.fromJson(cell)).toList());
    final data = GameData(clientId: id, board: board_, side: side_);
    _gameData.complete(data);
  }

  _onBoard(List data) async {
    final cells = data.map((cell) => Cell.fromJson(cell)).toList();

    final board = (await _gameData.future).board;
    boardsStreamController
        .add(Board(width: board.width, height: board.height, cells: cells));
  }

  _onSimulationReady() {
    _simulationReady.complete(true);
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
