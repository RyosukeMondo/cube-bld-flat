import 'package:flutter/material.dart';
import '../models/defs.dart';

class WorldController extends ChangeNotifier {
  double rotX = 18 * (3.1415926535 / 180.0);
  double rotY = -22 * (3.1415926535 / 180.0);
  double zoomZ = 0; // logical px

  CellDef? selectedA;
  CellDef? selectedB;
  bool lockA = false;
  bool lockB = false;

  final List<CellDef> defsRef;

  WorldController({required this.defsRef});

  String? get _currentKind {
    if (selectedA != null) return selectedA!.kind;
    if (selectedB != null) return selectedB!.kind;
    return null;
  }

  bool _isSelectable(CellDef def) {
    if (def.kind == 'center') return false; // centers are not selectable
    final k = _currentKind;
    if (k == null) return true; // first pick can be edge or corner
    return def.kind == k; // subsequent picks must match first kind
  }

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
    // Enforce selection restrictions by kind
    if (!_isSelectable(def)) {
      return;
    }
    // Respect lock states. Try to fill empty slots; if both filled:
    // - If both unlocked: third tap clears previous A/B and sets new A (original policy)
    // - If A locked and B not: set B = def
    // - If B locked and A not: set A = def
    // - If both locked: ignore
    if (selectedA == null) {
      selectedA = def;
      notifyListeners();
      return;
    }
    if (selectedB == null) {
      selectedB = def;
      notifyListeners();
      return;
    }
    // both are set
    if (lockA && lockB) {
      return; // ignore taps when both locked
    }
    if (lockA && !lockB) {
      selectedB = def;
      notifyListeners();
      return;
    }
    if (!lockA && lockB) {
      selectedA = def;
      notifyListeners();
      return;
    }
    // both unlocked -> original policy
    selectedA = def;
    selectedB = null;
    notifyListeners();
  }

  void clearSelection() {
    selectedA = null;
    selectedB = null;
    lockA = false;
    lockB = false;
    notifyListeners();
  }

  void resetView() {
    rotX = 18 * (3.1415926535 / 180.0);
    rotY = -22 * (3.1415926535 / 180.0);
    zoomZ = 0;
    notifyListeners();
  }

  void toggleLockFor(CellDef def) {
    // Enforce selection restrictions for lock assignment as well
    if (def.kind == 'center') {
      return;
    }
    final k = _currentKind;
    if (k != null && def.kind != k) {
      return;
    }
    if (selectedA == def) {
      lockA = !lockA;
      notifyListeners();
      return;
    }
    if (selectedB == def) {
      lockB = !lockB;
      notifyListeners();
      return;
    }
    // Not currently selected: assign and lock to an available slot
    if (selectedA == null) {
      selectedA = def;
      lockA = true;
      notifyListeners();
      return;
    }
    if (selectedB == null) {
      selectedB = def;
      lockB = true;
      notifyListeners();
      return;
    }
    // Both set
    if (lockA && lockB) {
      return; // both locked; ignore
    }
    if (lockA && !lockB) {
      selectedB = def;
      lockB = true;
      notifyListeners();
      return;
    }
    if (!lockA && lockB) {
      selectedA = def;
      lockA = true;
      notifyListeners();
      return;
    }
    // both unlocked -> replace A and lock it
    selectedA = def;
    selectedB = null;
    lockA = true;
    lockB = false;
    notifyListeners();
  }
}
