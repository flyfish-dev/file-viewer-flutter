/// Inclusive HTTP byte range, converted to an exclusive end for Dart streams.
({int start, int end})? parseViewerByteRange(String? header, int length) {
  if (header == null) return (start: 0, end: length);
  final match = RegExp(r'^bytes=(\d*)-(\d*)$').firstMatch(header.trim());
  if (match == null ||
      length <= 0 ||
      (match[1]!.isEmpty && match[2]!.isEmpty)) {
    return null;
  }
  if (match[1]!.isEmpty) {
    final suffix = int.tryParse(match[2]!);
    if (suffix == null || suffix <= 0) return null;
    return (start: suffix >= length ? 0 : length - suffix, end: length);
  }
  final start = int.tryParse(match[1]!);
  final last = match[2]!.isEmpty ? length - 1 : int.tryParse(match[2]!);
  if (start == null || last == null || start >= length || last < start) {
    return null;
  }
  return (start: start, end: last >= length ? length : last + 1);
}
