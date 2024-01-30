import 'dart:convert';
import 'dart:core' hide Match;
import 'dart:developer';
import 'package:celloffun_backend/match.dart';
import 'package:celloffun_backend/session.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final Session session = Session(); //test

class Connection {
  final String id;
  final WebSocketChannel channel;
  late final String name;
  ConnectedState state;

  Connection(
    this.channel,
  )   : state = Idle(),
        id = Uuid().v1();

  handle() => channel.stream.listen(_handle);

  _handle(dynamic data) => switch (jsonDecode(data)) {
        {'status': 'handshake', 'name': String name} => _onHandshake(name),
        {'status': 'ready', 'strategy': final strategy} =>
          _onReady(jsonDecode(strategy)),
        _ => _notOk(data)
      };

  _onHandshake(String name) async {
    assert(state is Idle);
    this.name = name;
    state = Connected(session: session);
    _ok();
    final data = await session.getGameData(id);
    channel.sink.add(data);

    session.connections.add(this);
    session.sessionStreamController.stream.pipe(channel.sink);

    if (session.checkPlayersConnected()) {
      session.processLobbyCountdown();
    }
  }

  _onReady(strategy) {
    assert(state is Connected);
    final session = (state as Connected).session;
    state = Ready(
        session: session,
        matches: (strategy['matches'] as List)
            .map((m) => Match.fromJson(m, id))
            .toList(),
        points: (strategy['points'] as List).cast<int>());

    if (session.checkReadiness()) {
      session.startSimulation();
    }
  }

  _ok() {
    channel.sink.add(jsonEncode({'id': id, 'status': 'ok'}));
    log('OK: $name : $id', time: DateTime.timestamp());
  }

  _notOk(data) {
    channel.sink.add('error');
    log('ERROR: $name : $id', time: DateTime.timestamp(), error: data);
  }
}

sealed class ConnectedState {}

class Idle extends ConnectedState {}

class Connected extends ConnectedState {
  final Session session;

  Connected({required this.session});
}

class Ready extends Connected {
  final List<Match> matches;
  final List<int> points;
  Ready({
    required super.session,
    required this.matches,
    required this.points,
  });
}
