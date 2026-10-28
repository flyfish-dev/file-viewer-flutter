import 'dart:convert';

import 'package:file_viewer_flutter/file_viewer_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'offline previews, real Worker/WASM, and retained route sessions',
    (tester) async {
      final runtime = FileViewerRuntime();
      final controller = FileViewerController();
      final source = ValueNotifier<FileViewerSource>(
        const FileViewerSource.asset('assets/sample.txt'),
      );
      final visible = ValueNotifier<bool>(true);
      final events = <String>[];
      final errors = <Object>[];
      final timings = <Map<String, Object?>>[];
      var documentReady = 0;
      await tester.pumpWidget(
        FileViewerHost(
          runtime: runtime,
          child: MaterialApp(
            home: Scaffold(
              body: ListenableBuilder(
                listenable: Listenable.merge([source, visible]),
                builder: (_, _) => !visible.value
                    ? const SizedBox.shrink()
                    : FileViewer(
                        source: source.value,
                        runtime: runtime,
                        controller: controller,
                        onEvent: (event) {
                          events.add(event.type);
                          if (event.type == 'documentReady') documentReady++;
                        },
                        onError: errors.add,
                      ),
              ),
            ),
          ),
        ),
      );
      Future<void> waitFor(bool Function() ready) async {
        final deadline = DateTime.now().add(const Duration(seconds: 90));
        while (!ready()) {
          if (errors.isNotEmpty) fail('Preview failed: ${errors.first}');
          if (DateTime.now().isAfter(deadline)) {
            fail('Timed out waiting for document; events: $events');
          }
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      Future<T> command<T>(Future<T> Function() operation) async {
        var done = false;
        T? result;
        Object? failure;
        operation().then(
          (value) {
            result = value;
            done = true;
          },
          onError: (Object error) {
            failure = error;
            done = true;
          },
        );
        // Native platform-view attachment and renderer layout need normal
        // Flutter frames while a controller operation is in flight.
        await waitFor(() => done);
        if (failure != null) throw failure!;
        return result as T;
      }

      await waitFor(() => controller.isAttached && documentReady == 1);
      debugPrint('FILE_VIEWER_STEP initial document');
      final probe = await command(controller.probeRuntime);
      expect(probe['workerExecuted'], true);
      expect(probe['wasmResult'], 42);
      for (final filename in [
        'sample.pdf',
        'sample.docx',
        'sample.xlsx',
        'sample.pptx',
        'sample.txt',
      ]) {
        final expected = documentReady + 1;
        final timer = Stopwatch()..start();
        source.value = FileViewerSource.asset('assets/$filename');
        await waitFor(() => documentReady >= expected);
        timings.add({
          'format': filename.split('.').last,
          'elapsedMs': timer.elapsedMilliseconds,
        });
        expect(
          (await command(controller.getCapabilities)).operations,
          isNotEmpty,
        );
        debugPrint('FILE_VIEWER_STEP $filename');
      }
      final loadsBeforeReopen = events
          .where((event) => event == 'load-start')
          .length;
      for (var iteration = 0; iteration < 5; iteration++) {
        visible.value = false;
        await tester.pump();
        await tester.pump();
        await waitFor(() => runtime.activeSessionCount == 0);
        final expected = documentReady + 1;
        final timer = Stopwatch()..start();
        visible.value = true;
        await waitFor(() => documentReady >= expected);
        expect(runtime.activeSessionCount, 1);
        expect((await command(controller.probeRuntime))['wasmResult'], 42);
        timings.add({
          'reopen': iteration + 1,
          'elapsedMs': timer.elapsedMilliseconds,
        });
        debugPrint('FILE_VIEWER_STEP reopen ${iteration + 1}');
      }
      expect(
        events.where((event) => event == 'load-start').length,
        loadsBeforeReopen,
        reason: 'Reopening the same retained source must not parse the document again.',
      );
      visible.value = false;
      await tester.pump();
      await tester.pump();
      await waitFor(() => runtime.activeSessionCount == 0);
      await command(
        () =>
            runtime.preload(const FileViewerSource.asset('assets/sample.pdf')),
      );
      debugPrint('FILE_VIEWER_STEP idle preload');
      final preloadedExpected = documentReady + 1;
      source.value = const FileViewerSource.asset('assets/sample.pdf');
      visible.value = true;
      await waitFor(() => documentReady >= preloadedExpected);
      expect((await command(controller.probeRuntime))['wasmResult'], 42);
      await command(controller.close);
      debugPrint('FILE_VIEWER_STEP close');
      await command(
        () =>
            controller.load(const FileViewerSource.asset('assets/sample.txt')),
      );
      expect(runtime.activeSessionCount, 1);
      binding.reportData = {
        'workerProbe': probe,
        'timings': timings,
        'events': events,
      };
      debugPrint('FILE_VIEWER_EVIDENCE ${jsonEncode(binding.reportData)}');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await runtime.shutdown();
      controller.dispose();
      source.dispose();
      visible.dispose();
    },
  );
}
