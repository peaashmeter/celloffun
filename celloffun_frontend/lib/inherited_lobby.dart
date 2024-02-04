import 'package:celloffun_frontend/lobby_data.dart';
import 'package:flutter/material.dart';

class InheritedLobby extends InheritedNotifier {
  final LobbyData data;
  const InheritedLobby({super.key, required this.data, required super.child})
      : super(notifier: data);

  @override
  bool updateShouldNotify(covariant InheritedLobby oldWidget) => true;

  static InheritedLobby of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedLobby>()!;
}
