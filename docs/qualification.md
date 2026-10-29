# Qualification matrix

This is a development preview. A platform metadata entry is not a support guarantee. Raw measurements and customer-free screenshots remain in `.release/` and CI artifacts; this file records only reproducible scope.

| Target | Initial evidence | Still required for qualification |
| --- | --- | --- |
| Web | JS and Dart WASM release builds; Chrome 156 renders all five fixtures with external HTTP blocked; Worker/WASM executes | Retained-session lifecycle and representative mobile browsers |
| iOS | iPhone 17 Pro simulator / iOS 26.4: five fixtures, Worker/WASM, five reattachments without parsing again, idle PDF preload, close/reload | Physical iPhone/iPad, memory pressure, background recovery and representative format corpus |
| Android | Xiaomi 12 Pro / API 35 / WebView 131: five fixtures, Worker/WASM, five reattachments without parsing again, idle PDF preload, close/reload | Older/current WebView matrix, memory pressure, background recovery and representative format corpus |
| macOS / Apple Silicon | macOS 27.0.1 / Xcode 27: native build, six fixtures, Worker/WASM, nine viewport checks, five reattachments, idle PDF preload and close/reload; macOS 15 ARM64 CI also has a complete validation receipt | Older macOS versions, memory pressure, background recovery and representative format corpus |
| macOS / Intel | Physical MacBookPro16,2 / x86_64 / macOS 26.7.1 / Xcode 26.0: published `0.1.0-dev.2`, native WKWebView build, six fixtures, Worker/WASM, nine viewport checks, five reattachments without parsing again, idle PDF preload and close/reload; complete validation receipt | Older macOS versions, memory pressure, background recovery and representative format corpus |
| Windows | Windows 2025 x64 / Windows 11 ARM64 CI: native builds, Microsoft-signed fixed WebView2 runtime, five fixtures, Worker/WASM, five reattachments, idle PDF preload and close/reload | More Windows versions, memory pressure, background recovery and representative format corpus |
| Linux | Ubuntu 24.04 x64/ARM64 CI: native builds, sandbox startup, five fixtures, Worker/WASM, five reattachments, idle PDF preload and close/reload | More distributions, real desktop visual checks, memory pressure and representative format corpus |

Flutter `3.47.4` / Dart `3.13.3` is the current pinned build toolchain. Initial device targets are Android 24+, iOS 15+, macOS 12+, Windows 10+, and explicitly qualified Linux distributions. File formats, memory capacity, codecs and system WebView versions remain part of the compatibility contract.

Do not advertise "all devices", stable six-platform support, instant first render, or every format being preinitialized until the corresponding measurements and tests exist.

Native driver runs must include the `completed: true` receipt written after all
checks and cleanup. A process exit or a summary saying "All tests passed" without
that receipt is insufficient evidence. The publication score is checked
separately with Pana and dartdoc; 160 pub points does not replace device testing.

## Intel macOS validation — 2026-10-29

The physical Intel run used Flutter `3.47.4` / Dart `3.13.3`, a native x86_64
toolchain, and a separate consumer of the seven published `0.1.0-dev.2` packages.
No local package overrides were used. All seven published archive hashes and
all 3,119 bundled resources were verified before the native run.

The [integration test](../example/integration_test/viewer_test.dart) checks actual
rendered bounds as well as controller state. Excel stays at natural size for a
small sheet, shrinks in a narrow viewport, preserves manual zoom during resize,
and returns to automatic fit on request. PPTX is contained within landscape,
portrait and small viewports, including a `280 × 300` viewport below the engine's
25% zoom floor. Page selection survives entering and leaving slideshow mode.
Five hide/reopen cycles add no document parsing events; idle preload, close,
reload and shutdown also complete.

To reproduce, use the repository's example and driver. In an isolated copy, set
`file_viewer_flutter: 0.1.0-dev.2` in the example's dependencies and omit
`pubspec_overrides.yaml`. Run the following from the `example/` directory:

```sh
flutter pub get
dart run file_viewer_flutter:setup --project . --platform macos --apply
flutter build macos --debug --no-pub \
  --target integration_test/viewer_test.dart \
  --dart-define=FILE_VIEWER_DIAGNOSTICS=true
flutter drive --driver test_driver/integration_test.dart \
  --target integration_test/viewer_test.dart \
  --use-application-binary "build/macos/Build/Products/Debug/File Viewer.app" \
  --debug -d macos --no-pub
```

Require `build/integration_response_data.json` to contain `completed: true`, six
file timings, nine viewport measurements, five reopen timings, and a successful
Worker/WASM probe. These debug-run timings are diagnostic measurements, not a
production performance benchmark. Intel macOS validation is maintained on
physical x86_64 hardware. Automated desktop CI covers macOS ARM64, Windows
x64/ARM64 and Linux x64/ARM64.
