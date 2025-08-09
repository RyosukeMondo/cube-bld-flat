import 'package:flutter/material.dart';
import '../models/defs.dart';

class WorldController extends ChangeNotifier {
  double rotX = 18 * (3.1415926535 / 180.0);
  double rotY = -22 * (3.1415926535 / 180.0);
  double zoomZ = 0; // logical px

  CellDef? selectedA;
  CellDef? selectedB;

  final List<CellDef> defsRef;

  WorldController({required this.defsRef});

  void onDrag(Offset delta) {
    // mimic JS: rotY += dx*0.3; rotX -= dy*0.3; clamp rotX
    final dx = delta.dx;
    final dy = delta.dy;
    rotY += (dx * 0.3) * (3.1415926535 / 180.0);
    rotX -= (dy * 0.3) * (3.1415926535 / 180.0);
    final maxX = 89 * (3.1415926535 / 180.0);
    if (rotX > maxX) rotX = maxX;
    if (rotX < -maxX) rotX = -maxX;
    notifyListeners();
  }

  void onZoom(double dz) {
    zoomZ += dz;
    if (zoomZ > 900) zoomZ = 900;
    if (zoomZ < -900) zoomZ = -900;
    notifyListeners();
  }

  void select(CellDef def) {
    // Policy: third tap clears previous A and B and set new A
    if (selectedA == null) {
      selectedA = def;
    } else if (selectedB == null) {
      selectedB = def;
    } else {
      selectedA = def;
      selectedB = null;
    }
    notifyListeners();
  }

  void clearSelection() {
    selectedA = null;
    selectedB = null;
    notifyListeners();
  }

  void resetView() {
    rotX = 18 * (3.1415926535 / 180.0);
    rotY = -22 * (3.1415926535 / 180.0);
    zoomZ = 0;
    notifyListeners();
  }
}
