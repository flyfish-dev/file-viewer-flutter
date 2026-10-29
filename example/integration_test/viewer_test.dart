import 'dart:convert';

import 'package:file_viewer_flutter/file_viewer_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
    // Native WebViews and their viewport changes need the same live-frame
    // scheduling as an ordinary app, including frames between explicit pumps.
    ..framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

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
        'presentation-tour.pptx',
        'sample.txt',
      ]) {
        final expected = documentReady + 1;
        final timer = Stopwatch()..start();
        source.value = FileViewerSource.asset('assets/$filename');
        await waitFor(() => documentReady >= expected);
        timings.add({
          'file': filename,
          'format': filename.split('.').last,
          'elapsedMs': timer.elapsedMilliseconds,
        });
        expect(
          (await command(controller.getCapabilities)).operations,
          isNotEmpty,
        );
        step(filename);
        if (filename == 'sample.pdf') {
          Object? presentationError;
          try {
            await command(() => controller.setPresentationMode(true));
          } catch (error) {
            presentationError = error;
          }
          expect(
            presentationError,
            isA<FileViewerException>().having(
              (error) => error.code,
              'code',
              FileViewerErrorCode.unsupportedOperation,
            ),
          );
        }
        if (filename == 'presentation-tour.pptx') {
          final loads = events.where((event) => event == 'load-start').length;
          var state = await command(controller.getViewState) as Map;
          expect(state['pageCount'], 3);
          await command(() => controller.applyViewState({'page': 2}));
          state = await command(controller.getViewState) as Map;
          expect(state['page'], 2);
          await command(() => controller.setPresentationMode(true));
          state = await command(controller.getViewState) as Map;
          expect((state['extra'] as Map)['presenting'], true);
          expect(state['page'], 2);
          expect((state['extra'] as Map)['presentationPage'], 2);
          await command(() => controller.applyViewState({'page': 3}));
          state = await command(controller.getViewState) as Map;
          expect((state['extra'] as Map)['presentationPage'], 3);
          await command(() => controller.setPresentationMode(false));
          state = await command(controller.getViewState) as Map;
          expect((state['extra'] as Map)['presenting'], false);
          expect(state['page'], 3);
          await command(() => controller.applyViewState({'page': 1}));
          state = await command(controller.getViewState) as Map;
          expect(state['page'], 1);
          expect(events.where((event) => event == 'load-start').length, loads);
        }
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
        if (filename == 'sample.pptx') {
          final loads = events.where((event) => event == 'load-start').length;
          Future<void> assertPresentationFit(String label) async {
            step('$label: fit requested');
            final fit = await command(controller.fit) as Map;
            step('$label: fit returned');
            expect(
              fit['applied'],
              true,
              reason: 'PPTX must implement the shared fit contract.',
            );
            var state = await command(controller.getViewState) as Map;
            final layoutDeadline = DateTime.now().add(
              const Duration(seconds: 10),
            );
            // The public engine schedules native WebView layout across frames.
            // Qualify the eventual rendered bounds, not just its desired scale.
            while (true) {
              final extra = state['extra'] as Map;
              final rendered = extra['renderedSlide'] as Map?;
              final dimensions = extra['slideDimensions'] as Map;
              final hostViewport = extra['hostViewport'] as Map;
              final available = extra['viewport'] as Map;
              final scale = (state['scale'] as num).toDouble();
              final widthFit =
                  (available['width'] as num) / (dimensions['width'] as num);
              final heightFit =
                  (available['height'] as num) / (dimensions['height'] as num);
              final expectedFit = widthFit < heightFit ? widthFit : heightFit;
              final nativeBounds = tester.getSize(find.byKey(viewportKey));
              if (rendered != null &&
                  ((hostViewport['width'] as num) - nativeBounds.width).abs() <
                      1 &&
                  (scale - expectedFit).abs() < 0.015 &&
                  ((rendered['width'] as num) -
                              (dimensions['width'] as num) * scale)
                          .abs() <
                      1 &&
                  ((rendered['height'] as num) -
                              (dimensions['height'] as num) * scale)
                          .abs() <
                      1) {
                break;
              }
              if (DateTime.now().isAfter(layoutDeadline)) {
                fail('PPTX layout did not settle: ${jsonEncode(state)}');
              }
              await tester.pump(const Duration(milliseconds: 100));
              state = await command(controller.getViewState) as Map;
            }
            final scroll = state['scroll'] as Map;
            final extra = state['extra'] as Map;
            final dimensions = extra['slideDimensions'] as Map;
            final viewport = extra['viewport'] as Map;
            final rendered = extra['renderedSlide'] as Map;
            final width = (viewport['width'] as num).toDouble();
            final height = (viewport['height'] as num).toDouble();
            final slideWidth = (dimensions['width'] as num).toDouble();
            final slideHeight = (dimensions['height'] as num).toDouble();
            final actualScale = (state['scale'] as num).toDouble();
            final expectedScale = (width / slideWidth < height / slideHeight)
                ? width / slideWidth
                : height / slideHeight;
            expect(actualScale, closeTo(expectedScale, 0.015));
            expect(slideWidth * actualScale, lessThanOrEqualTo(width + 1));
            expect(slideHeight * actualScale, lessThanOrEqualTo(height + 1));
            expect(
              (scroll['width'] as num).toDouble(),
              lessThanOrEqualTo((scroll['clientWidth'] as num).toDouble() + 1),
              reason:
                  'A fitted slide must not leave an unscaled scroll extent.',
            );
            expect(
              (rendered['width'] as num).toDouble(),
              closeTo(slideWidth * actualScale, 1),
            );
            expect(
              (rendered['height'] as num).toDouble(),
              closeTo(slideHeight * actualScale, 1),
            );
            expect(
              (scroll['clientHeight'] as num).toDouble(),
              greaterThan(
                tester.getSize(find.byKey(viewportKey)).height * 0.65,
              ),
            );
            await recordViewport(label);
            step('$label: rendered bounds verified');
          }

          await assertPresentationFit('PPTX fills the bounded viewport');
          final fitted = await readScale();
          await command(controller.zoomIn);
          final enlarged = await readScale();
          expect(
            enlarged,
            greaterThan(fitted),
            reason: 'Zoom in must never shrink a fitted slide.',
          );
          await command(controller.zoomOut);
          expect(await readScale(), closeTo(fitted, 0.001));
          await command(controller.resetZoom);
          expect(await readScale(), closeTo(1, 0.001));
          viewport.value = const Size(420, 580);
          await tester.pump(const Duration(milliseconds: 300));
          expect(await readScale(), closeTo(1, 0.001));
          await assertPresentationFit('PPTX portrait viewport fit');
          viewport.value = const Size(280, 300);
          await tester.pump(const Duration(milliseconds: 300));
          await assertPresentationFit(
            'PPTX small viewport fits below engine zoom floor',
          );
          viewport.value = const Size(800, 320);
          await tester.pump(const Duration(milliseconds: 300));
          await assertPresentationFit('PPTX short landscape viewport fit');
          final readingScale = await readScale();
          await command(() => controller.setPresentationMode(true));
          var state = await command(controller.getViewState) as Map;
          expect((state['extra'] as Map)['presenting'], true);
          final slide = (state['extra'] as Map)['renderedSlide'] as Map;
          final bounds = tester.getSize(find.byKey(viewportKey));
          expect(
            (slide['width'] as num).toDouble(),
            lessThanOrEqualTo(bounds.width + 1),
          );
          expect(
            (slide['height'] as num).toDouble(),
            lessThanOrEqualTo(bounds.height + 1),
          );
          await command(() => controller.setPresentationMode(false));
          state = await command(controller.getViewState) as Map;
          expect((state['extra'] as Map)['presenting'], false);
          expect(await readScale(), closeTo(readingScale, 0.001));
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
      final evidence = {
        'workerProbe': probe,
        'timings': timings,
        'events': events,
        'viewportMeasurements': viewportMeasurements,
      };
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await runtime.shutdown();
      controller.dispose();
      source.dispose();
      visible.dispose();
      viewport.dispose();
      binding.reportData = {...evidence, 'completed': true};
      debugPrint('FILE_VIEWER_EVIDENCE ${jsonEncode(binding.reportData)}');
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
