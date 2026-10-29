import 'dart:convert';

import 'package:file_viewer_flutter/file_viewer_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'offline previews, adaptive viewports, Worker/WASM, and retained sessions',
    (tester) async {
      final runtime = FileViewerRuntime();
      final controller = FileViewerController();
      final source = ValueNotifier<FileViewerSource>(
        const FileViewerSource.asset('assets/sample.txt'),
      );
      final visible = ValueNotifier<bool>(true);
      final viewport = ValueNotifier<Size>(const Size(720, 440));
      final viewportMeasurements = <Map<String, Object?>>[];
      const viewportKey = ValueKey('native-viewport');
      final events = <String>[];
      final errors = <Object>[];
      final timings = <Map<String, Object?>>[];
      var documentReady = 0;
      final elapsed = Stopwatch()..start();
      void step(String label) => debugPrintSynchronously(
        'FILE_VIEWER_STEP ${elapsed.elapsedMilliseconds}ms $label '
        'lifecycle=${binding.lifecycleState} frames=${binding.framesEnabled}',
      );
      await tester.pumpWidget(
        FileViewerHost(
          runtime: runtime,
          child: MaterialApp(
            home: Scaffold(
              body: ListenableBuilder(
                listenable: Listenable.merge([source, visible, viewport]),
                builder: (_, _) => Align(
                  alignment: Alignment.topLeft,
                  child: !visible.value
                      ? const SizedBox.shrink()
                      : SizedBox.fromSize(
                          size: viewport.value,
                          child: FileViewer(
                            key: viewportKey,
                            source: source.value,
                            runtime: runtime,
                            controller: controller,
                            onEvent: (event) {
                              events.add(event.type);
                              if (event.type == 'documentReady') {
                                documentReady++;
                              }
                            },
                            onError: errors.add,
                          ),
                        ),
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
      Future<double> readScale() async {
        final state = await command(controller.getViewState) as Map;
        return ((state['scale'] ?? (state['zoom'] as Map?)?['scale']) as num)
            .toDouble();
      }

      Future<void> waitForScale(bool Function(double) accepts) async {
        final deadline = DateTime.now().add(const Duration(seconds: 10));
        while (true) {
          await tester.pump(const Duration(milliseconds: 100));
          final scale = await readScale();
          if (accepts(scale)) return;
          if (DateTime.now().isAfter(deadline)) {
            fail('Unexpected sheet scale: $scale');
          }
        }
      }

      Future<void> recordViewport(String label) async {
        final actual = tester.getSize(find.byKey(viewportKey));
        viewportMeasurements.add({
          'step': label,
          'width': actual.width,
          'height': actual.height,
          'scale': await readScale(),
        });
        expect(tester.takeException(), isNull);
      }

      step('initial document');
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
        step(filename);
        if (filename == 'sample.xlsx') {
          final loads = events.where((event) => event == 'load-start').length;
          await waitForScale((scale) => (scale - 1).abs() < 0.01);
          await recordViewport('small sheet stays at natural size');
          viewport.value = const Size(280, 300);
          await waitForScale((scale) => scale > 0 && scale < 1);
          await recordViewport('narrow viewport shrinks the sheet');
          expect(tester.getSize(find.byKey(viewportKey)), const Size(280, 300));
          viewport.value = const Size(720, 440);
          await waitForScale((scale) => (scale - 1).abs() < 0.01);
          await recordViewport('wide viewport stops at natural size');
          await command(controller.zoomIn);
          final manualScale = await readScale();
          expect(manualScale, greaterThan(1));
          viewport.value = const Size(360, 260);
          await tester.pump(const Duration(milliseconds: 300));
          expect(await readScale(), closeTo(manualScale, 0.001));
          await recordViewport('manual zoom survives resize');
          await command(controller.fit);
          expect(await readScale(), lessThanOrEqualTo(1));
          await recordViewport('auto fit restores adaptive layout');
          expect(events.where((event) => event == 'load-start').length, loads);
          viewport.value = const Size(720, 440);
        }
      }
      final loadsBeforeReopen = events
          .where((event) => event == 'load-start')
          .length;
      for (var iteration = 0; iteration < 5; iteration++) {
        step('hide ${iteration + 1}');
        visible.value = false;
        await tester.pump();
        step('hide frame 1');
        await tester.pump();
        step('hide frame 2');
        await waitFor(() => runtime.activeSessionCount == 0);
        step('released ${iteration + 1}');
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
        step('reopen ${iteration + 1}');
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
      step('idle preload');
      final preloadedExpected = documentReady + 1;
      source.value = const FileViewerSource.asset('assets/sample.pdf');
      visible.value = true;
      await waitFor(() => documentReady >= preloadedExpected);
      expect((await command(controller.probeRuntime))['wasmResult'], 42);
      await command(controller.close);
      step('close');
      await command(
        () =>
            controller.load(const FileViewerSource.asset('assets/sample.txt')),
      );
      expect(runtime.activeSessionCount, 1);
      binding.reportData = {
        'workerProbe': probe,
        'timings': timings,
        'events': events,
        'viewportMeasurements': viewportMeasurements,
      };
      debugPrint('FILE_VIEWER_EVIDENCE ${jsonEncode(binding.reportData)}');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await runtime.shutdown();
      controller.dispose();
      source.dispose();
      visible.dispose();
      viewport.dispose();
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
