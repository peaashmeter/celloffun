import 'package:celloffun_frontend/cell.dart';
import 'package:celloffun_frontend/connection.dart';
import 'package:celloffun_frontend/widgets/cell_widget.dart';
import 'package:flutter/material.dart';

import '../inherited_lobby.dart';

class PaletteCell extends StatelessWidget {
  final Cell cell;
  const PaletteCell({
    super.key,
    required this.cell,
  });

  @override
  Widget build(BuildContext context) {
    final data = InheritedLobby.of(context).data;
    final selectedCell = data.selectedCell;
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
              width: 2,
              color: selectedCell == cell
                  ? Colors.green
                  : Theme.of(context).colorScheme.secondary)),
      child: CellWidget(
        onTap: () {
          data.selectCell(cell);
        },
        clientId: InheritedGameData.of(context).data.clientId,
        cell: cell,
      ),
    );
  }
}
