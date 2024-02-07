import 'dart:convert';
import 'dart:core' hide Match;
import 'dart:developer';
import 'dart:math' hide log;
import 'package:celloffun_backend/match.dart';
import 'package:celloffun_backend/session.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Connection {
  final Map<String, Session> sessions;

  final String id;
  final WebSocketChannel channel;
  late final String name;
  ConnectedState state;

  Connection(this.channel, this.sessions)
      : state = Idle(),
        id = Uuid().v1();

  handle() => channel.stream.listen(_handle);

  _handle(dynamic data) => switch (jsonDecode(data)) {
        {
          'status': 'handshake',
          'session': String? sessionId,
          'name': String name
        } =>
          _onHandshake(name, sessionId),
        {'status': 'ready', 'strategy': final strategy} =>
          _onReady(jsonDecode(strategy)),
        _ => _notOk(data)
      };

  _onHandshake(String name, String? sessionId) async {
    assert(state is Idle);
    this.name = name;

    try {
      final session = switch (sessionId) {
        null => _createSession(),
        _ => _findSession(sessionId)
      };
      state = Connected(session: session);

      _ok();

      final data = await session.getGameData(id);
      channel.sink.add(data);

      session.connections.add(this);

      session.sessionStreamController.stream.listen((event) {
        channel.sink.add(event);
      });

      if (session.checkPlayersConnected()) {
        session.sendOpponentNames();
        session.processLobbyCountdown();
      }
    } catch (e) {
      log(e.toString());
      _notOk('COULD_NOT_CONNECT');
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

    if (session.checkPlayersConnected() && session.checkReadiness()) {
      session.startSimulation();
    }
  }

  Session _createSession() {
    final id = (Random().nextInt(90000) + 10000).toString();
    if (sessions.containsKey(id)) {
      return _createSession();
    }
    final session = Session(id)
      ..waitForClose().then((value) => sessions.remove(id));

    Future.delayed(Duration(minutes: 15), () {
      if (session.closed) return;
      session.close();
    }); //Kill inactive sessions
    sessions[id] = session;
    return sessions[id]!;
  }

  Session _findSession(id) {
    if (!sessions.containsKey(id)) {
      throw Exception('No session with id: $id exist.');
    }
    if (sessions[id]!.connections.length > 1) {
      throw Exception('Session with id: $id is already full.');
    }
    return sessions[id]!;
  }

  _ok() {
    channel.sink.add(jsonEncode({'id': id, 'status': 'ok'}));
    log('OK: $name : $id', time: DateTime.timestamp());
  }

  _notOk(data) {
    channel.sink.add(jsonEncode({'error': data}));
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
