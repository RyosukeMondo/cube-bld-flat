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
            final matrix = Matrix4.identity()
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
                    BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 10)),
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
        child: Stack(children: [
          for (final d in controller.defsRef)
            _CellBox(
              def: d,
              onTap: () => controller.select(d),
            ),
        ]),
      ),
    );
  }
}

class _CellBox extends StatelessWidget {
  final CellDef def;
  final VoidCallback onTap;
  const _CellBox({required this.def, required this.onTap});

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

    final label = def.char == null
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

    final box = Stack(children: [
      Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: def.fill,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF1B2539)),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2))],
        ),
      ),
      if (def.char != null) label,
    ]);

    return Positioned(
      left: left,
      top: top,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
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
