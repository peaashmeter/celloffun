import 'package:celloffun_frontend/cell.dart';
import 'package:celloffun_frontend/strategy.dart';
import 'package:flutter/material.dart';

class LobbyData extends ChangeNotifier {
  late Cell selectedCell;
  late List<Match> matches;
  Set<int> startIndices = {};

  bool ready = false;
  bool showPatterns = false;

  LobbyData({
    required this.selectedCell,
    required this.matches,
    required this.ready,
  });

  void selectCell(Cell cell) {
    selectedCell = cell;
    notifyListeners();
  }

  void setPatternCell(Cell cell, int patternIndex, int cellIndex) {
    matches[patternIndex].pattern.cells[cellIndex] = cell;
    notifyListeners();
  }

  void setMatchResult(Cell cell, int matchIndex) {
    matches[matchIndex].result = cell;
    notifyListeners();
  }

  void addMatch(String clientId) {
    if (matches.length > 100) return;
    matches.add(Match.plain(clientId));
    notifyListeners();
  }

  void addStartIndex(int index) {
    startIndices.add(index);
  }

  void removeStartIndex(int index) {
    startIndices.remove(index);
  }

  void toogleDisplay(bool show) {
    showPatterns = show;
    notifyListeners();
  }
}
