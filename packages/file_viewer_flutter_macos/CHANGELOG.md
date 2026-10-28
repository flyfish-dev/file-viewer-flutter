# Changelog

## 0.1.0-dev.1

Initial isolated macOS adapter derived from InAppWebView 1.2.0-beta.3.
Retain the warmed WKWebView inside a separate NSView container per Flutter
platform-view ID to make delayed disposal of old attachments safe.
