import 'package:file_viewer_flutter/src/platform/navigation.dart';
import 'package:file_viewer_flutter/src/resources/range.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'range requests handle full, bounded, suffix and unsatisfiable reads',
    () {
      expect(parseViewerByteRange(null, 10), (start: 0, end: 10));
      expect(parseViewerByteRange('bytes=2-5', 10), (start: 2, end: 6));
      expect(parseViewerByteRange('bytes=8-', 10), (start: 8, end: 10));
      expect(parseViewerByteRange('bytes=-3', 10), (start: 7, end: 10));
      expect(parseViewerByteRange('bytes=0-99', 10), (start: 0, end: 10));
      for (final value in [
        'bytes=10-',
        'bytes=-0',
        'bytes=5-2',
        'bytes=0-1,4-5',
        'bytes=-',
      ]) {
        expect(parseViewerByteRange(value, 10), isNull);
      }
    },
  );
  test(
    'navigation distinguishes a trusted shell and inert preview subframes',
    () {
      final shell = Uri.parse('http://localhost:1234/token/assets/index.html');
      expect(
        isAllowedViewerNavigation(
          shell.replace(fragment: 'page-2'),
          shell,
          isMainFrame: true,
        ),
        isTrue,
      );
      for (final url in [
        'about:blank',
        'about:srcdoc',
        'blob:http://localhost:1234/uuid',
      ]) {
        expect(
          isAllowedViewerNavigation(Uri.parse(url), shell, isMainFrame: false),
          isTrue,
        );
        expect(
          isAllowedViewerNavigation(Uri.parse(url), shell, isMainFrame: true),
          isFalse,
        );
      }
      for (final url in [
        'mailto:a@example.test',
        'https://outside.test/',
        'javascript:alert(1)',
        'blob:https://outside.test/uuid',
        'file:///tmp/x',
      ]) {
        expect(
          isAllowedViewerNavigation(Uri.parse(url), shell, isMainFrame: false),
          isFalse,
        );
      }
    },
  );
}
