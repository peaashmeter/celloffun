import 'package:celloffun_frontend/cell.dart';
import 'package:celloffun_frontend/connection.dart';
import 'package:celloffun_frontend/inherited_lobby.dart';
import 'package:flutter/material.dart';

import 'palette_cell.dart';

class CellPalette extends StatelessWidget {
  const CellPalette({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final clientId = InheritedGameData.of(context).data.clientId;

    if (!InheritedLobby.of(context).data.showPatterns) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 60,
      child: Material(
        elevation: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            PaletteCell(
              cell: Cell(CellTypes.alive, owner: clientId),
            ),
            PaletteCell(
              cell: Cell(CellTypes.dead, owner: clientId),
            ),
            PaletteCell(
              cell: Cell(CellTypes.void_, owner: clientId),
            ),
            const PaletteCell(
              cell: Cell(CellTypes.alive, owner: 'enemy'),
            ),
          ],
        ),
      ),
    );
  }
}
