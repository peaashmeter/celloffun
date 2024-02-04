import 'package:flutter/material.dart';

import '../inherited_lobby.dart';

class LobbyTools extends StatelessWidget {
  const LobbyTools({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final data = InheritedLobby.of(context).data;
    return Column(
      children: [
        CheckboxListTile(
            title: const Text('Переключить отображение'),
            value: data.showPatterns,
            onChanged: (value) => data.toogleDisplay(value ?? false))
      ],
    );
  }
}
