import 'package:celloffun_frontend/cell.dart';
import 'package:flutter/material.dart';

class CellWidget extends StatelessWidget {
  final Cell cell;
  final Function() onTap;
  final String clientId;
  const CellWidget({
    super.key,
    required this.onTap,
    required this.clientId,
    required this.cell,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 33,
      height: 33,
      child: Material(
        color: cell.getColor(clientId),
        child: InkWell(
          onTap: () {
            onTap();
          },
        ),
      ),
    );
  }
}
