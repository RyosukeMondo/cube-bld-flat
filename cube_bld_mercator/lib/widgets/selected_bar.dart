import 'package:flutter/material.dart';
import '../controllers/world_controller.dart';
import '../models/algorithms.dart';

class SelectedBar extends StatelessWidget {
  final WorldController controller;
  const SelectedBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final a = controller.selectedA?.key ?? '-';
        final b = controller.selectedB?.key ?? '-';
        final algo = _lookupAlgo(a, b);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2232),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF273149)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _pill(label: 'A', value: a),
                  const SizedBox(width: 8),
                  _pill(label: 'B', value: b),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: controller.clearSelection,
                    child: const Text('Clear'),
                  ),
                ],
              ),
              if (algo != null) ...[
                const SizedBox(height: 8),
                Text(
                  algo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                  softWrap: true,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _pill({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1421),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF273149)),
      ),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String? _lookupAlgo(String a, String b) {
    if (a == '-' || b == '-') return null;
    final isCorner = a.isNotEmpty && a[0].toUpperCase() == a[0];
    if (isCorner) {
      return Algorithms.corners[b]?[a];
    } else {
      return Algorithms.edges[b]?[a];
    }
  }
}
