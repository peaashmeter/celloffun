import 'package:flutter/material.dart';

enum CellTypes { dead, alive, void_ }

class Cell {
  final CellTypes type;
  final String? owner;

  const Cell(this.type, {this.owner});
  Cell.fromJson(Map json)
      : type = switch (json['type']) {
          'dead' => CellTypes.dead,
          'alive' => CellTypes.alive,
          _ => CellTypes.void_
        },
        owner = json['owner'];

  toJson() => {
        'type': switch (type) {
          CellTypes.dead => 'dead',
          CellTypes.alive => 'alive',
          _ => 'void',
        },
        'owner': owner
      };

  Color getColor(String clientId) => switch (type) {
        CellTypes.dead => Colors.white,
        CellTypes.void_ => Colors.black,
        CellTypes.alive when owner == clientId => Colors.blue,
        _ => Colors.red
      };

  @override
  int get hashCode => Object.hash(type, owner);

  @override
  bool operator ==(Object other) {
    if (other is! Cell) return false;
    return other.owner == owner && other.type == type;
  }
}
