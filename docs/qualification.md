# Qualification matrix

This is a development preview. A platform metadata entry is not a support guarantee. Raw measurements and customer-free screenshots remain in `.release/` and CI artifacts; this file records only reproducible scope.

| Target | Initial evidence | Still required for qualification |
| --- | --- | --- |
| Web | JS and Dart WASM release builds; Chrome 156 renders all five fixtures with external HTTP blocked; Worker/WASM executes | Retained-session lifecycle and representative mobile browsers |
| iOS | iPhone 17 Pro simulator / iOS 26.4: five fixtures, Worker/WASM, five reattachments without parsing again, idle PDF preload, close/reload | Physical iPhone/iPad, memory pressure, background recovery and representative format corpus |
| Android | Xiaomi 12 Pro / API 35 / WebView 131: five fixtures, Worker/WASM, five reattachments without parsing again, idle PDF preload, close/reload | Older/current WebView matrix, memory pressure, background recovery and representative format corpus |
| macOS | Apple Silicon / macOS 26 / Xcode 27: native build, five fixtures, Worker/WASM, five reattachments, idle PDF preload and close/reload | Intel matrix, memory pressure, background recovery and representative format corpus |
| Windows | Fixed WebView2 runtime archive hashes locked for x64/ARM64 | Native builds, signed-runtime checks, fixtures and lifecycle |
| Linux | CEF archive hashes locked for x64/ARM64; sandbox enabled in adapter | Native builds, sandbox startup, fixtures and lifecycle on named distributions |

Flutter `3.47.4` / Dart `3.13.3` is the current pinned build toolchain. Initial device targets are Android 24+, iOS 15+, macOS 12+, Windows 10+, and explicitly qualified Linux distributions. File formats, memory capacity, codecs and system WebView versions remain part of the compatibility contract.

Do not advertise "all devices", stable six-platform support, instant first render, or every format being preinitialized until the corresponding measurements and tests exist.
