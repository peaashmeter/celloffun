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
}
