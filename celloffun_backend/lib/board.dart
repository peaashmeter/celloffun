import 'dart:core' hide Match, Pattern;
import 'dart:math';

import 'package:celloffun_backend/cell.dart';
import 'package:celloffun_backend/match.dart';
import 'package:celloffun_backend/pattern.dart';

class Board {
  static const width = 100;
  static const height = 100;
  final int iteration;

  final List<Cell> cells;

  const Board({required this.cells, this.iteration = 0});

  factory Board.empty() => Board(
          cells: List.generate(width * height, (i) {
        final (x, y) = (i % width, i ~/ height);
        if (x == 0 || x == width - 1) return const Void();
        if (y == 0 || y == height - 1) return const Void();
        return const DeadCell();
      }));

  factory Board.random() => Board(
          cells: List.generate(width * height, (i) {
        if (Random().nextInt(10) > 7) return const Void();
        return const DeadCell();
      }));

  factory Board.daynight() {
    var b = Board.random();
    for (var i = 0; i < 10; i++) {
      b = b._iterateDayNight();
    }
    return b;
  }

  Board iterate(List<Match> matches) {
    final newCells = List.generate(width * height, (index) => index).map((i) {
      final (x, y) = (i % width, i ~/ height);

      final neighbors = [
        (x - 1, y - 1),
        (x, y - 1),
        (x + 1, y - 1),
        (x - 1, y),
        (x, y),
        (x + 1, y),
        (x - 1, y + 1),
        (x, y + 1),
        (x + 1, y + 1)
      ].map((point) {
        return switch (height * point.$2 + point.$1) {
          final i_ && >= 0 => cells.elementAtOrNull(i_),
          _ => null
        };
      }).toList();

      final pattern = Pattern(cells: neighbors);
      final initial = pattern.center!;
      final results = <Cell>{};

      for (final match in matches) {
        if (match.matches(pattern)) {
          results.add(match.result);
        }
      }
      if (results.length == 1) return results.single;
      return initial;
    }).toList();

    return Board(cells: newCells, iteration: iteration + 1);
  }

  Board _iterateDayNight() {
    final newCells = List.generate(width * height, (index) => index).map((i) {
      final (x, y) = (i % width, i ~/ height);

      final neighbors = [
        (x - 1, y - 1),
        (x, y - 1),
        (x + 1, y - 1),
        (x - 1, y),
        (x + 1, y),
        (x - 1, y + 1),
        (x, y + 1),
        (x + 1, y + 1)
      ].map((point) {
        return switch (height * point.$2 + point.$1) {
          final i_ && >= 0 => cells.elementAtOrNull(i_),
          _ => null
        };
      }).toList();

      if (neighbors.whereType<DeadCell>().length case 3 || 6 || 7 || 8) {
        return const DeadCell();
      }
      if (neighbors.whereType<Void>().length case 3 || 6 || 7 || 8) {
        return const Void();
      }
      return cells[i];
    }).toList();

    return Board(cells: newCells);
  }
}
