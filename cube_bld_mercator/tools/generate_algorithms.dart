// Dart script to generate lib/models/algorithms.dart from data CSV files.
// It parses lines by commas but respects bracket nesting (e.g., commas inside [ ... ] are kept).
// Rows = B (first column key), Columns = A (header keys). Lookup: table[row][col].
// CSV is assumed to have two header rows: [label, map, <cols...>] and [map, ... descriptions ...].
// The rest are rows: [rowKey, description, <cells...>].
// This script is intended to be run manually when CSV changes (though user says CSV won't update).
// Usage: dart tools/generate_algorithms.dart

import 'dart:io';

void main() {
  final repoRoot = Directory.current.path;
  // Adjust paths relative to project root: cube_bld_mercator
  // Data lives at ../../data from this script if run in project root.
  final edgesCsv = File('${repoRoot.replaceAll('\\', '/')}/../data/algo_edges.csv');
  final cornersCsv = File('${repoRoot.replaceAll('\\', '/')}/../data/algo_corners.csv');

  if (!edgesCsv.existsSync() || !cornersCsv.existsSync()) {
    stderr.writeln('Could not find CSV files. Expected at:');
    stderr.writeln('  ${edgesCsv.path}');
    stderr.writeln('  ${cornersCsv.path}');
    exit(1);
  }

  final edges = _parseCsv(edgesCsv.readAsLinesSync());
  final corners = _parseCsv(cornersCsv.readAsLinesSync());

  final outFile = File('lib/models/algorithms.dart');
  outFile.createSync(recursive: true);
  outFile.writeAsStringSync(_emitDart(edges: edges, corners: corners));
  stdout.writeln('Generated ${outFile.path}');
}

class TableData {
  // Map<rowKey, Map<colKey, value>>
  final Map<String, Map<String, String>> table;
  // Ordered keys for possible validation/inspection (not used by app code).
  final List<String> rowKeys;
  final List<String> colKeys;
  TableData(this.table, this.rowKeys, this.colKeys);
}

TableData _parseCsv(List<String> lines) {
  if (lines.isEmpty) {
    throw ArgumentError('Empty CSV');
  }
  // Split lines respecting bracket nesting
  List<String> splitSmart(String line) {
    // Determine delimiter: prefer comma if present outside brackets; otherwise try tab; else collapse on 1+ spaces.
    String delimiter = ',';
    bool hasCommaOutside = false;
    int depth = 0;
    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '[') depth++;
      if (ch == ']') depth = depth > 0 ? depth - 1 : 0;
      if (ch == ',' && depth == 0) {
        hasCommaOutside = true;
        break;
      }
    }
    if (!hasCommaOutside) {
      if (line.contains('\t')) {
        delimiter = '\t';
      } else {
        delimiter = ' '; // will handle runs of spaces below
      }
    }

    final result = <String>[];
    final buf = StringBuffer();
    depth = 0; // reset
    void flush() {
      result.add(buf.toString());
      buf.clear();
    }

    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '[') depth++;
      if (ch == ']') depth = depth > 0 ? depth - 1 : 0;
      if (depth == 0) {
        if (delimiter == ',') {
          if (ch == ',') {
            flush();
            continue;
          }
        } else if (delimiter == '\t') {
          if (ch == '\t') {
            flush();
            continue;
          }
        } else {
          // space-delimited: split on runs of spaces
          if (ch == ' ') {
            // lookahead: if next is also space, keep consuming; but we only flush when we have non-empty token
            if (buf.isNotEmpty) {
              flush();
            }
            // skip consecutive spaces
            while (i + 1 < line.length && line[i + 1] == ' ') {
              i++;
            }
            continue;
          }
        }
      }
      buf.write(ch);
    }
    flush();
    return result.map((s) => s.trim()).toList();
  }

  final header1 = splitSmart(lines[0]);
  if (header1.length < 3 || header1[0] != 'label' || header1[1] != 'map') {
    throw FormatException('Unexpected header row 1: ${lines[0]}');
  }
  final header2 = splitSmart(lines[1]);
  if (header2.length < 3 || header2[0] != 'map') {
    throw FormatException('Unexpected header row 2: ${lines[1]}');
  }

  // Column keys start at index 2 in header1
  final colKeys = header1.sublist(2).map((s) => _keyFromHeaderCell(s)).toList();

  final table = <String, Map<String, String>>{};
  final rowKeys = <String>[];

  for (int li = 2; li < lines.length; li++) {
    final row = splitSmart(lines[li]);
    if (row.isEmpty) continue;
    // Expect: rowKey, description, then cells for each column
    if (row.length < 2) continue;
    final rowKey = _keyFromHeaderCell(row[0]);
    rowKeys.add(rowKey);

    final cells = <String, String>{};
    final max = row.length;
    for (int ci = 2; ci < max && (ci - 2) < colKeys.length; ci++) {
      final colKey = colKeys[ci - 2];
      final val = row[ci].trim();
      if (val.isEmpty) continue;
      cells[colKey] = val;
    }
    table[rowKey] = cells;
  }

  return TableData(table, rowKeys, colKeys);
}

String _keyFromHeaderCell(String raw) {
  // The files use forms like: "d" or "あ (UB)" or just letter tokens.
  // We prefer the Latin single-letter key when present. Use the first Latin letter sequence,
  // else fall back to the first token.
  final trimmed = raw.trim();
  final letter = RegExp(r'[A-Za-z]')
      .allMatches(trimmed)
      .map((m) => m.group(0)!)
      .toList();
  if (letter.isNotEmpty) return letter.first;
  // If no ASCII letter, try the first non-space char
  return trimmed.isNotEmpty ? trimmed[0] : trimmed;
}

String _emitDart({required TableData edges, required TableData corners}) {
  String emitMap(Map<String, Map<String, String>> m) {
    final sb = StringBuffer();
    sb.writeln('{');
    final rowKeys = m.keys.toList();
    rowKeys.sort();
    for (final r in rowKeys) {
      sb.writeln("  '$r': {");
      final inner = m[r]!;
      final colKeys = inner.keys.toList();
      colKeys.sort();
      for (final c in colKeys) {
        final raw = inner[c]!;
        final val = raw
            .replaceAll('\\', r'\\')
            .replaceAll('"', r'\\"')
            .replaceAll('\$', r'\$');
        sb.writeln("    '$c': \"$val\",");
      }
      sb.writeln('  },');
    }
    sb.writeln('}');
    return sb.toString();
  }

  return """
// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated by tools/generate_algorithms.dart

class Algorithms {
  // Edges: lookup by row (B) then column (A)
  static const Map<String, Map<String, String>> edges = ${emitMap(edges.table)};

  // Corners: lookup by row (B) then column (A)
  static const Map<String, Map<String, String>> corners = ${emitMap(corners.table)};

  /// Lookup algorithm by selection.
  /// A is the column key, B is the row key.
  /// Uses corners when both are uppercase, else edges when both are lowercase.
  /// Returns null if not found or if mixed case.
  static String? lookup(String? a, String? b) {
    if (a == null || b == null || a.isEmpty || b.isEmpty) return null;
    final isAUpper = _isUpper(a);
    final isBUpper = _isUpper(b);
    if (isAUpper && isBUpper) {
      return corners[b]?[a];
    } else if (!isAUpper && !isBUpper) {
      return edges[b]?[a];
    }
    return null; // mixed case selections are not defined
  }

  static bool _isUpper(String s) => s.toUpperCase() == s && s.toLowerCase() != s;
}
""";
}
