# Changelog

## Unreleased

- Fill the native PPTX viewport, implement page/width fitting and absolute zoom,
  and add slide navigation and Flutter-controlled slideshow entry and exit.
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

