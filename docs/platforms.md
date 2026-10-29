# Platform setup

One Dart API targets six platforms through their WebView or Web DOM implementation. This release is a development preview; a platform tag does not qualify every device, OS version or document format.

## Shared setup

Complete the [quick start](quickstart.md), then preview and apply host configuration from your application root:

```sh
dart run file_viewer_flutter:setup --project . --check
dart run file_viewer_flutter:setup --project . --apply
```

Only existing platform directories are processed. Run it again after adding a platform. Select a subset with `--platform android,ios,macos`; `web` is not an argument to this command.

## Android

- Initial target: Android API 24+, using the installed Android WebView.
- Setup adds Internet permission and loopback-scoped local HTTP configuration. Existing custom settings are preserved or a conflict is reported for review.
- No separate Android Service, perpetual background permission or foreground-service permission is required.
- Fully rebuild the APK after changing host settings. Verify your actual device and installed WebView version.

Initial evidence: Xiaomi 12 Pro / API 35 / WebView 131, five owned fixtures, Worker/WASM execution, session reuse and document preload.

## iOS

- Initial target: iOS 15+, using WKWebView. Build on macOS with Xcode and Flutter's iOS tooling.
- Setup handles Info.plist entries for local resources while preserving the meaning of your existing network policy.
- The OS can suspend or reclaim background processes; see [warm-up and lifecycle](runtime.md).

Initial evidence: iPhone 17 Pro / iOS 26.4 simulator. Physical iPhones/iPads, memory pressure and a broader document corpus remain stable-release gates.

## Web

- Uses browser DOM and same-origin static assets; native setup makes no Web changes.
- Deploy the complete `build/web/`, including `assets/packages/` and CanvasKit/Skwasm resources.
- Browsers cannot open arbitrary native paths. Read a file-picker selection into `FileViewerSource.bytes`.
- Authenticated cross-origin URLs remain subject to browser CORS.

```sh
flutter build web --no-web-resources-cdn
```

Initial evidence: Chrome 156, JavaScript and Dart WASM builds, five owned formats, and real Worker/WASM execution with external HTTP blocked. Mobile browsers need separate verification.

## macOS

- Initial target: macOS 12+, using WKWebView. Use Xcode and Flutter's macOS toolchain.
- Setup adds Info.plist and sandbox network entitlements needed by local resources while preserving other settings.
- Retained WKWebViews and document sessions use a fresh native container on each Flutter attachment, keeping one View from attaching to multiple Widgets.

Verified on physical Apple Silicon / macOS 27.0.1 and Intel / macOS 26.7.1 devices, with additional macOS 15 ARM64 CI coverage. Both physical architectures passed six document fixtures, nine PPTX/Excel viewport checks, Worker/WASM execution and five session reattachments without parsing again. PPTX fits landscape, portrait and small viewports; small spreadsheets remain at natural size and manual zoom survives resizing. See the [qualification matrix](https://github.com/flyfish-dev/file-viewer-flutter/blob/main/docs/qualification.md) for exact environments and reproducible checks. App signing and notarization remain part of your application's distribution process.

## Windows

- Initial target: Windows 10+, using a bundled, checksum-locked WebView2 Fixed Version Runtime.
- Use Flutter's supported Windows / Visual Studio C++ build environment. Ship the complete release output and its bundled browser runtime.
- The build prepares the locked engine archive; the application does not download an engine at runtime.

Initial evidence: Windows 2025 x64 and Windows 11 ARM64 CI, actual rendering and Microsoft runtime signature verification. Qualify other versions in your target environment.

## Linux

- Uses a bundled, checksum-locked CEF adapter with its sandbox preserved.
- Typical build dependencies include clang, CMake, Ninja, pkg-config, GTK 3, ALSA, NSS, XSS and GBM; package names vary by distribution.
- Setup adds CEF subprocess initialization and shutdown ordering to the Linux runner and connects its build configuration.
- Systems allowing unprivileged user namespaces can use that sandbox path. Restricted distributions require a normal installer to assign the bundled `chrome-sandbox` helper its official root ownership and `4755` mode. Do not silently elevate the app or disable the sandbox.

Initial evidence: Ubuntu 24.04 x64 / ARM64 CI. Other distributions, display servers and real desktop visuals need separate checks.

## Qualify your target

The repository's [qualification matrix](https://github.com/flyfish-dev/file-viewer-flutter/blob/main/docs/qualification.md) records measured scope and remaining release gates. Test your own documents, devices, memory conditions and system WebViews. Another platform or desktop browser is not physical-iOS evidence.
