# File Viewer Flutter example

A responsive document workspace with bundled, locally generated PDF, Word,
Excel, PowerPoint and text samples. No customer documents or remote preview
service are used.

```sh
flutter pub get
dart run file_viewer_flutter:setup --project . --apply
flutter run
```

Wide windows show a document sidebar; compact windows use the document selector.
The top controls provide automatic fit, width/page/actual-size views and theme.
Presentations also have a Flutter-native slideshow button. Use the arrow keys,
Space or Page Up / Page Down to navigate; press Escape or use the same button
to leave slideshow mode and continue reading the current slide.

The PowerPoint entry opens `presentation-tour.pptx`, an owned three-slide deck
covering text layout, shapes, an embedded transparent project logo and navigation.
The unchanged, single-line `sample.pptx` remains an integration regression fixture.
Regenerate both with `python3 tool/create-fixtures.py` from the repository root.

See the [integration guide](https://flutter.file-viewer.app/en/docs/quickstart/)
and the repository's [qualification scope](../docs/qualification.md). New main-branch
features are listed under Unreleased in [CHANGELOG.md](../CHANGELOG.md).
