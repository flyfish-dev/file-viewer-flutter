# File Viewer Flutter Linux adapter

Linux-only integration derived from webview_cef 0.6.2 (Apache-2.0).
See UPSTREAM.json for the immutable source archive and its SHA-256.

Host runner changes are explicit: run the File Viewer setup CLI before building.
CEF is prepared at build time and included in the application's offline bundle.
Runtime downloads are not used. Linux qualification is tracked separately from
the Dart API and other native platforms.

