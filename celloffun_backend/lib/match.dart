import 'dart:core' hide Pattern;
import 'package:celloffun_backend/cell.dart';
import 'package:celloffun_backend/pattern.dart';

class Match {
  final String owner;
  final Pattern pattern;
  final Cell result;

  const Match(
      {required this.pattern, required this.result, required this.owner});
  Match.fromJson(json, this.owner)
      : pattern = Pattern.fromJson(json['pattern']),
        result = Cell.fromJson(json['result']);

  bool matches(Pattern sample) => (pattern.equals(sample));

  ///Player sends patterns where their opponent's cells are marked as 'enemy'.
  ///This remakes the match with the id of actual opponent.
  Match normalize(String actualId) => Match(
      pattern: Pattern(
          cells: pattern.cells.map((c) {
        if (c is AliveCell && c.owner == 'enemy') {
          return AliveCell(owner: actualId);
        }
        return c;
      }).toList()),
      result: switch (result) {
        AliveCell(owner: 'enemy') => AliveCell(owner: actualId),
        _ => result
      },
      owner: owner);
}
