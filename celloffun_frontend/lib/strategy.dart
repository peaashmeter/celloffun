import 'package:celloffun_frontend/cell.dart';

class Pattern {
  final List<Cell?> cells;

  const Pattern({required this.cells});

  Cell? get center => cells[cells.length ~/ 2];

  toJson() => {'cells': cells.map((cell) => cell!.toJson()).toList()};
}

class Match {
  final Pattern pattern;
  Cell result;

  Match({required this.pattern, required this.result});

  Match.plain(String clientId)
      : pattern = Pattern(
            cells: List<Cell>.generate(
          9,
          (index) => index == 4
              ? Cell(CellTypes.alive, owner: clientId)
              : Cell(CellTypes.dead, owner: clientId),
        )),
        result = Cell(CellTypes.alive, owner: clientId);

  toJson() => {'pattern': pattern.toJson(), 'result': result.toJson()};
}

class Strategy {
  List<int> points = [];
  List<Match> matches = [];

  Strategy(this.matches, this.points);

  toJson() => {
        'matches': matches.map((match) => match.toJson()).toList(),
        'points': points
      };
}
