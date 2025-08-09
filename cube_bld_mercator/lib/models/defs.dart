import 'package:flutter/material.dart';

// Grid and unit sizes
const int gridW = 11;
const int gridH = 13;
const double unit = 36; // px-equivalent logical
const double zUnit = 12; // depth per z level

// Colors (match POC)
class CubeColors {
  static const leftBand = Color(0xFFC9743C);
  static const rightBand = Color(0xFFEF1A1A);
  static const yellow = Color(0xFFEFE23A);
  static const back = Color(0xFF8FB2E9);
  static const top = Color(0xFFFFFFFF);
  static const front = Color(0xFFB7F47A);
  static const textDark = Color(0xFF10141B);
  static const textLight = Color(0xFF0E0E10);
}

class CellDef {
  final String key;
  final int x1, y1, x2, y2;
  final Color fill;
  final String? char;
  final int z;

  const CellDef({
    required this.key,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.fill,
    this.char,
    this.z = 0,
  });
}

class Cell {
  final Color? fill;
  final String? char;
  final String? key;
  const Cell({this.fill, this.char, this.key});
}

class GridResult {
  final List<List<Cell>> grid;
  final List<CellDef> defs;
  const GridResult(this.grid, this.defs);
}

GridResult buildGrid(List<CellDef> definitions) {
  final grid = List.generate(
    gridH,
    (_) => List.generate(gridW, (_) => const Cell()),
  );
  for (final d in definitions) {
    for (int y = d.y1; y <= d.y2; y++) {
      for (int x = d.x1; x <= d.x2; x++) {
        grid[y][x] = Cell(fill: d.fill, char: d.char, key: d.key);
      }
    }
  }
  return GridResult(grid, definitions);
}

// Ported defs from JS
final List<CellDef> defs = [
  // Base bands
  const CellDef(key: 'j', x1: 0, y1: 0, x2: 3, y2: 12, fill: CubeColors.leftBand, char: 'j', z: 0),
  const CellDef(key: 'r', x1: 7, y1: 0, x2: 10, y2: 12, fill: CubeColors.rightBand, char: 'r', z: 0),

  // second large bands
  const CellDef(key: 'J', x1: 1, y1: 1, x2: 3, y2: 5, fill: CubeColors.leftBand, char: 'J', z: 1),
  const CellDef(key: 'k', x1: 2, y1: 3, x2: 3, y2: 5, fill: CubeColors.leftBand, char: 'k', z: 2),
  const CellDef(key: 'K', x1: 3, y1: 4, x2: 3, y2: 5, fill: CubeColors.leftBand, char: 'K', z: 3),

  const CellDef(key: 'I', x1: 1, y1: 7, x2: 3, y2: 11, fill: CubeColors.leftBand, char: 'I', z: 1),
  const CellDef(key: 'i', x1: 2, y1: 7, x2: 3, y2: 9, fill: CubeColors.leftBand, char: 'i', z: 2),
  const CellDef(key: 'L', x1: 3, y1: 7, x2: 3, y2: 8, fill: CubeColors.leftBand, char: 'L', z: 3),

  const CellDef(key: 'Q', x1: 7, y1: 1, x2: 9, y2: 5, fill: CubeColors.rightBand, char: 'Q', z: 1),
  const CellDef(key: 'q', x1: 7, y1: 3, x2: 8, y2: 5, fill: CubeColors.rightBand, char: 'q', z: 2),
  const CellDef(key: 'T', x1: 7, y1: 4, x2: 7, y2: 5, fill: CubeColors.rightBand, char: 'T', z: 3),

  const CellDef(key: 'R', x1: 7, y1: 7, x2: 9, y2: 11, fill: CubeColors.rightBand, char: 'R', z: 1),
  const CellDef(key: 'r', x1: 7, y1: 7, x2: 8, y2: 9, fill: CubeColors.rightBand, char: 'r', z: 2),
  const CellDef(key: 'S', x1: 7, y1: 7, x2: 7, y2: 8, fill: CubeColors.rightBand, char: 'S', z: 3),

  // center faces
  const CellDef(key: 'Down0', x1: 5, y1: 0, x2: 5, y2: 0, fill: CubeColors.yellow, char: 'Down', z: 0),
  const CellDef(key: 'Back', x1: 5, y1: 3, x2: 5, y2: 3, fill: CubeColors.back, char: 'Back', z: 2),
  const CellDef(key: 'Top', x1: 5, y1: 6, x2: 5, y2: 6, fill: CubeColors.top, char: 'Top', z: 3),
  const CellDef(key: 'Front', x1: 5, y1: 9, x2: 5, y2: 9, fill: CubeColors.front, char: 'Front', z: 2),
  const CellDef(key: 'Down1', x1: 5, y1: 12, x2: 5, y2: 12, fill: CubeColors.yellow, char: 'Down', z: 0),
  const CellDef(key: 'Left', x1: 2, y1: 6, x2: 2, y2: 6, fill: CubeColors.leftBand, char: 'Left', z: 2),
  const CellDef(key: 'Right', x1: 8, y1: 6, x2: 8, y2: 6, fill: CubeColors.rightBand, char: 'Right', z: 2),

  // other small cells
  const CellDef(key: 'w0', x1: 4, y1: 0, x2: 4, y2: 0, fill: CubeColors.yellow, char: 'w', z: 0),
  const CellDef(key: 'u0', x1: 6, y1: 0, x2: 6, y2: 0, fill: CubeColors.yellow, char: 'u', z: 0),

  const CellDef(key: 'V', x1: 4, y1: 1, x2: 4, y2: 1, fill: CubeColors.yellow, char: 'V', z: 1),
  const CellDef(key: 'v', x1: 5, y1: 1, x2: 5, y2: 1, fill: CubeColors.yellow, char: 'v', z: 1),
  const CellDef(key: 'U', x1: 6, y1: 1, x2: 6, y2: 1, fill: CubeColors.yellow, char: 'U', z: 1),

  const CellDef(key: 'M', x1: 4, y1: 2, x2: 4, y2: 2, fill: CubeColors.back, char: 'M', z: 1),
  const CellDef(key: 'n', x1: 5, y1: 2, x2: 5, y2: 2, fill: CubeColors.back, char: 'n', z: 1),
  const CellDef(key: 'N', x1: 6, y1: 2, x2: 6, y2: 2, fill: CubeColors.back, char: 'N', z: 1),

  const CellDef(key: 'm', x1: 4, y1: 3, x2: 4, y2: 3, fill: CubeColors.back, char: 'm', z: 2),
  const CellDef(key: 'o', x1: 6, y1: 3, x2: 6, y2: 3, fill: CubeColors.back, char: 'o', z: 2),

  const CellDef(key: 'P', x1: 4, y1: 4, x2: 4, y2: 4, fill: CubeColors.back, char: 'P', z: 3),
  const CellDef(key: 'p', x1: 5, y1: 4, x2: 5, y2: 4, fill: CubeColors.back, char: 'p', z: 3),
  const CellDef(key: 'O', x1: 6, y1: 4, x2: 6, y2: 4, fill: CubeColors.back, char: 'O', z: 3),

  const CellDef(key: 'C', x1: 4, y1: 5, x2: 4, y2: 5, fill: CubeColors.top, char: 'C', z: 3),
  const CellDef(key: 'd', x1: 5, y1: 5, x2: 5, y2: 5, fill: CubeColors.top, char: 'd', z: 3),
  const CellDef(key: 'D', x1: 6, y1: 5, x2: 6, y2: 5, fill: CubeColors.top, char: 'D', z: 3),

  const CellDef(key: 'l', x1: 3, y1: 6, x2: 3, y2: 6, fill: CubeColors.leftBand, char: 'l', z: 3),
  const CellDef(key: 'c', x1: 4, y1: 6, x2: 4, y2: 6, fill: CubeColors.top, char: 'c', z: 3),
  const CellDef(key: 'a', x1: 6, y1: 6, x2: 6, y2: 6, fill: CubeColors.top, char: 'a', z: 3),
  const CellDef(key: 't', x1: 7, y1: 6, x2: 7, y2: 6, fill: CubeColors.rightBand, char: 't', z: 3),

  const CellDef(key: 'B', x1: 4, y1: 7, x2: 4, y2: 7, fill: CubeColors.top, char: 'B', z: 3),
  const CellDef(key: 'b', x1: 5, y1: 7, x2: 5, y2: 7, fill: CubeColors.top, char: 'b', z: 3),
  const CellDef(key: 'A', x1: 6, y1: 7, x2: 6, y2: 7, fill: CubeColors.top, char: 'A', z: 3),

  const CellDef(key: 'G', x1: 4, y1: 8, x2: 4, y2: 8, fill: CubeColors.front, char: 'G', z: 3),
  const CellDef(key: 'h', x1: 5, y1: 8, x2: 5, y2: 8, fill: CubeColors.front, char: 'h', z: 3),
  const CellDef(key: 'H', x1: 6, y1: 8, x2: 6, y2: 8, fill: CubeColors.front, char: 'H', z: 3),

  const CellDef(key: 'g', x1: 4, y1: 9, x2: 4, y2: 9, fill: CubeColors.front, char: 'g', z: 2),
  const CellDef(key: 'e', x1: 6, y1: 9, x2: 6, y2: 9, fill: CubeColors.front, char: 'e', z: 2),

  const CellDef(key: 'F', x1: 4, y1: 10, x2: 4, y2: 10, fill: CubeColors.front, char: 'F', z: 1),
  const CellDef(key: 'f', x1: 5, y1: 10, x2: 5, y2: 10, fill: CubeColors.front, char: 'f', z: 1),
  const CellDef(key: 'E', x1: 6, y1: 10, x2: 6, y2: 10, fill: CubeColors.front, char: 'E', z: 1),

  const CellDef(key: 'W', x1: 4, y1: 11, x2: 4, y2: 11, fill: CubeColors.yellow, char: 'W', z: 1),
  const CellDef(key: 'x', x1: 5, y1: 11, x2: 5, y2: 11, fill: CubeColors.yellow, char: 'x', z: 1),
  const CellDef(key: 'X', x1: 6, y1: 11, x2: 6, y2: 11, fill: CubeColors.yellow, char: 'X', z: 1),

  const CellDef(key: 'w1', x1: 4, y1: 12, x2: 4, y2: 12, fill: CubeColors.yellow, char: 'w', z: 0),
  const CellDef(key: 'u1', x1: 6, y1: 12, x2: 6, y2: 12, fill: CubeColors.yellow, char: 'u', z: 0),
];
