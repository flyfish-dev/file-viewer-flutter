# Changelog

## Unreleased

## 0.1.0-dev.2

- Document the public Dart API, lifecycle contracts, sources, capabilities and
  recovery behavior; enforce public-member documentation in static analysis.
- Support XML 7.1 with current namespace-aware constructors and regression checks
  for Android and Apple host setup.
- Score the exact validated publication archive with Pana and dartdoc in CI;
  retain the report and reject any lost pub points.
- Fill the native PPTX viewport, implement page/width fitting and absolute zoom,
  and add slide navigation and Flutter-controlled slideshow entry and exit.
- Support sub-25% fitting on older WebKit with a clipped transform frame that
  preserves actual slide bounds and scroll extents.
- Keep delayed, layout-generated scroll events from disabling automatic fitting
  while native WebView viewport changes are still arriving.
- Restore format-aware automatic fitting instead of forcing width fitting on all
  documents; small spreadsheets keep their natural size.
- Expose the initial `FileViewer.fit` policy and restore automatic fitting with
  `FileViewerController.fit()`.
- Add a responsive example workspace, compact document picker and native macOS
  window sizing with saved window bounds.
- Add branded English and Chinese repository READMEs with a prominent main-project link.

## 0.1.0-dev.1

Initial development release of the Flutter API, application-scoped warm-up,
offline resource packaging, session pooling, and platform integration examples.
Platform qualification is required before a stable release.

