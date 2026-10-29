# Offline delivery

The rendering core, Workers, WASM, fonts and vendor assets ship in Flutter resource packages. Documents render locally without a separate conversion server.

## Payload and size

`file_viewer_flutter` pins four asset packages—base, CAD, drawing and Typst—and first-party Linux and macOS adapters. The current resources total approximately 225 MiB before application compression. This is not the final installed size on every platform.

Customer applications do not install npm packages or run JavaScript copy-assets commands. Preserve complete resources and matching versions; do not use public CDNs to fill missing production assets. Measure your target platform's own release build for size estimates.

## Web static deployment

```sh
flutter build web --no-web-resources-cdn
```

Deploy the entire `build/web/`. Package HTML, JavaScript, Workers, WASM, fonts and manifests are required alongside `index.html` and the main Dart JavaScript output.

Serve WASM as `application/wasm` and JavaScript with its correct MIME type. Do not let SPA fallback return HTML for a missing asset. Ensure your CSP permits the actual same-origin and Blob preview paths your application needs. Validate requests and browser errors against your organization's policy rather than copying an unrestricted global policy.

For the first offline check, inspect same-origin resource requests, block external requests and open owned fixtures. Remote document sources, embedded remote images and external links can still require a network.

## Windows and Linux engines

Windows bundles a checksum-locked WebView2 Fixed Version Runtime; Linux bundles checksum-locked CEF. Build machines need the locked archives for their platform and architecture or a populated cache. Build scripts verify SHA-256 before extraction; applications do not download engines at runtime.

For cache-only builds, prepare verified engine archives and set `FILE_VIEWER_OFFLINE_BUILD=1`. Missing archives fail the build. See [platform setup](platforms.md) for Linux sandbox requirements.

Android, iOS and macOS use their system WebViews. Installed engines, fonts and codec capabilities remain part of compatibility.

## Local SDK and isolated builds

A complete local SDK archive rewrites internal dependencies to relative paths for environments without pub.dev access. It differs from downloading only the root package's GitHub source: copying that package alone does not supply all resource and adapter packages.

Fully isolated builds also need a prepared Flutter SDK, every Dart dependency, platform toolchains and Windows/Linux engine caches. Runtime offline support and a completely offline build environment are distinct acceptance checks.

## Upgrades and production qualification

The current release is development preview `0.1.0-dev.1`. Upgrade the package family together, retain the lockfile, inspect host setup changes and retest first content, search/zoom, route reopen, background recovery and memory pressure on target devices.

Stable qualification still requires physical iOS devices, broader OS/device and document coverage, lifecycle checks and measured performance budgets. Consult the [qualification matrix](https://github.com/flyfish-dev/file-viewer-flutter/blob/main/docs/qualification.md).

## Licenses and attribution

The adapter uses Apache-2.0. Preserve upstream LICENSE/NOTICE files, resource ledgers, source offers and native-runtime licenses. The derived macOS adapter, Linux CEF and Windows runtime retain their own upstream terms.

The legacy PPT renderer retains its embedded watermark; integration does not bypass it. Format-specific use remains subject to the included licenses and applicable grants. Your application owns document selection, storage, access control and logout cleanup.
