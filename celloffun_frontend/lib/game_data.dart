import 'package:celloffun_frontend/cell.dart';

class Board {
  final int width;
  final int height;
  final List<Cell> cells;

  Board({required this.width, required this.height, required this.cells});
}

enum Sides { top, bottom }

class GameData {
  final String clientId;
  final Board board;
  final Sides side;

  GameData({required this.clientId, required this.board, required this.side});
}
