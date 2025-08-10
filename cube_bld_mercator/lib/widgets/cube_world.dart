import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../controllers/world_controller.dart';
import '../models/defs.dart';

class CubeWorld extends StatefulWidget {
  final WorldController controller;
  const CubeWorld({super.key, required this.controller});

  @override
  State<CubeWorld> createState() => _CubeWorldState();
}

class _CubeWorldState extends State<CubeWorld> {
  double _lastScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (signal) {
        if (signal is PointerScrollEvent) {
          // Match JS: zoomZ -= deltaY * 0.6
          widget.controller.onZoom(-(signal.scrollDelta.dy) * 0.6);
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onScaleStart: (_) => _lastScale = 1.0,
        onScaleUpdate: (details) {
          // Use focalPointDelta for rotation (pan), and scale for zoom.
          widget.controller.onDrag(details.focalPointDelta);
          final scale = details.scale;
          final dz = (scale - _lastScale) * 300; // adjust sensitivity
          if (dz.abs() > 0.01) {
            widget.controller.onZoom(dz);
          }
          _lastScale = scale;
        },
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            final matrix =
                Matrix4.identity()
                  ..setEntry(3, 2, 1 / -900) // perspective
                  ..translate(0.0, 0.0, widget.controller.zoomZ)
                  ..rotateX(widget.controller.rotX)
                  ..rotateY(widget.controller.rotY);

            return AspectRatio(
              aspectRatio: gridW / gridH,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1421),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 3D world
                    Transform(
                      alignment: Alignment.center,
                      transform: matrix,
                      child: _WorldContent(controller: widget.controller),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFECEFF4),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _WorldContent extends StatelessWidget {
  final WorldController controller;
  const _WorldContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    final width = gridW * unit;
    final height = gridH * unit;
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            for (final d in controller.defsRef)
              _CellBox(
                def: d,
                highlightA: controller.selectedA == d,
                highlightB: controller.selectedB == d,
                lockedA: controller.selectedA == d ? controller.lockA : false,
                lockedB: controller.selectedB == d ? controller.lockB : false,
                indicators: controller.sliceIndicatorsFor(d),
                onTap: () => controller.select(d),
                onDoubleTap: () => controller.toggleLockFor(d),
              ),
            // Legend shown only when a lock is active
            if (controller.lockA || controller.lockB)
              Positioned(
                left: (width / 2) - 160,
                bottom: -0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1421).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1B2539)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _LegendDot(color: Color(0xFFFFC107), label: 'E'),
                      const SizedBox(width: 10),
                      const _LegendDot(color: Color(0xFF26C6DA), label: 'M'),
                      const SizedBox(width: 10),
                      const _LegendDot(color: Color(0xFF9575CD), label: 'S'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CellBox extends StatelessWidget {
  final CellDef def;
  final bool highlightA;
  final bool highlightB;
  final bool lockedA;
  final bool lockedB;
  final Set<String> indicators;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  const _CellBox({
    required this.def,
    required this.onTap,
    required this.onDoubleTap,
    this.highlightA = false,
    this.highlightB = false,
    this.lockedA = false,
    this.lockedB = false,
    this.indicators = const {},
  });

  @override
  Widget build(BuildContext context) {
    final x = def.x1.toDouble();
    final y = def.y1.toDouble();
    final wCells = (def.x2 - def.x1 + 1).toDouble();
    final hCells = (def.y2 - def.y1 + 1).toDouble();
    final z = (def.z) * zUnit;

    final left = (x * unit + 1);
    final top = (y * unit + 1);
    final width = (wCells * unit - 2);
    final height = (hCells * unit - 2);

    // Label alignment similar to web
    final isLeft = def.fill == CubeColors.leftBand;
    final isRight = def.fill == CubeColors.rightBand;

    final label =
        def.char == null
            ? const SizedBox.shrink()
            : Positioned(
              left: isLeft ? 8 : null,
              right: isRight ? 8 : null,
              top: 0,
              bottom: 0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  def.char!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(0xFF0D1117),
                  ),
                ),
              ),
            );

    // Compute farthest-from-center corner and position helpers
    final centerX = (gridW * unit) / 2;
    final centerY = (gridH * unit) / 2;
    final cx = left + width / 2;
    final cy = top + height / 2;
    final useLeft = cx < centerX;
    final useTop = cy < centerY;

    // Inside placement in farthest corner (avoid overlap): small inset
    const inset = 4.0;

    const dotSize = 6.0;
    const dotGap = 3.0;
    const outside = 4.0; // how far outside the sticker we place indicators

    final box = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: def.fill,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF1B2539)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        if (highlightA || highlightB)
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color:
                    highlightA && highlightB
                        ? Colors.white
                        : (highlightA
                            ? const Color(0xFFFFC107)
                            : const Color(0xFF03A9F4)),
                width: 3,
              ),
            ),
          ),
        if (def.char != null) label,
        // Subtle E/M/S indicators as micro-dots when a lock is active, placed inside farthest corner
        if (indicators.isNotEmpty)
          Positioned(
            left: useLeft ? inset : null,
            right: useLeft ? null : inset,
            top: useTop ? inset : null,
            bottom: useTop ? null : inset,
            child: Tooltip(
              message: 'Slices: ' + indicators.join('/'),
              waitDuration: const Duration(milliseconds: 300),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (final s in ['E', 'M', 'S'])
                    if (indicators.contains(s))
                      Container(
                        width: dotSize,
                        height: dotSize,
                        margin: EdgeInsets.only(
                          right: useLeft ? dotGap : 0,
                          left: useLeft ? 0 : dotGap,
                        ),
                        decoration: BoxDecoration(
                          color:
                              s == 'E'
                                  ? const Color(0xFFFFC107) // amber for E
                                  : s == 'M'
                                  ? const Color(0xFF26C6DA) // teal for M
                                  : const Color(0xFF9575CD), // purple for S
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ),
          ),
        if (highlightA || highlightB)
          Positioned(
            left: useLeft ? -outside : null,
            right: useLeft ? null : -outside,
            top: useTop ? -outside : null,
            bottom: useTop ? null : -outside,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color:
                    highlightA && highlightB
                        ? Colors.white70
                        : (highlightA
                            ? const Color(0xFFFFD54F)
                            : const Color(0xFF40C4FF)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                () {
                  final base =
                      highlightA && highlightB
                          ? 'A/B'
                          : (highlightA ? 'A' : 'B');
                  final isLocked =
                      (highlightA && lockedA) || (highlightB && lockedB);
                  return isLocked
                      ? '$base\u{1F512}'
                      : base; // add lock 🔒 if locked
                }(),
                style: const TextStyle(
                  color: Color(0xFF0D1117),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );

    return Positioned(
      left: left,
      top: top,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..translate(0.0, 0.0, z),
            child: box,
          ),
        ),
      ),
    );
  }
}
