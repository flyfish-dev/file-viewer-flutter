# File Viewer Flutter

- Communicate in Simplified Chinese. Preserve unrelated changes.
- Edit source with apply_patch. Keep File Viewer rendering in its shared TypeScript core.
- Offline runtime: no public CDN, remote preview service, or runtime engine downloads.
- Use only immutable public upstream releases and verify archive and resource hashes.
- Keep upstream LICENSE/NOTICE, source offers, and the built-in legacy PPT watermark.
- Never commit customer documents, credentials, signing material, SDK caches, or private upstream files.
- Preview readiness, engine warm-up, and actual rendered first content are distinct states.
- One native view may be attached to only one widget at a time. Release idle instances on memory pressure.
- Use Xcode Simulator Safari and actual Flutter WKWebView for iOS verification; desktop WebKit is insufficient.
- Run flutter analyze, meaningful Dart tests, runtime bridge tests, and affected platform integration checks.
- Declare only measured platform support. Keep dynamic evidence in .release/<run>/CURRENT.json.
- Authorized repository: https://github.com/flyfish-dev/file-viewer-flutter.git. Authorized Dart namespace: file_viewer_flutter and file_viewer_flutter_* at https://pub.dev.
- Use business branch names and the repository-authorized Git identity. Never force-push or bypass protections.

