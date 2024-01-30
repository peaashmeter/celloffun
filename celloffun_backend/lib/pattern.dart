import 'package:celloffun_backend/cell.dart';

class Pattern {
  final List<Cell?> cells;

  const Pattern({required this.cells});

  Cell? get center => cells[cells.length ~/ 2];

  Pattern.fromJson(json)
      : cells =
            (json['cells'] as List).map((cell) => Cell.fromJson(cell)).toList();

  bool equals(Pattern other) =>
      cells.indexed.every((e) => other.cells[e.$1] == e.$2);
}
