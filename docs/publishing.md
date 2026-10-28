# Publishing the package family

Publish `0.1.0-dev.1` resource and platform packages before the app-facing
`file_viewer_flutter` package. The publisher is `flyfish.dev`. Keep the release
at development-preview status until the qualification gates pass.

Use the official Flutter/Dart pub client and a clean source checkout. Validate
isolated packages so the repository's top-level `.pubignore` cannot hide files
inside the component packages:

```sh
python3 tool/check-pub.py --staging-directory /absolute/empty/directory
```

The staging directory must be outside the repository. Root dependency overrides
are used only for validation before the internal packages exist in the registry.
Before publishing the entry package, remove its staging overrides and lockfile,
then resolve its dependencies from pub.dev.

Prefer `flutter pub publish` for normal uploads. If its large-file transfer is
unreliable, `flutter pub publish --to-archive /absolute/package.tar.gz` creates a
validated archive without publishing it. `tool/upload-pub-archive.py` uses the
same [official upload protocol](https://github.com/dart-lang/pub/blob/master/lib/src/command/lish.dart)
with HTTP/2. It verifies every archive file against staging, sends OAuth only to
pub.dev, restricts storage uploads to Google's supplied endpoint, and checks the
registry archive SHA-256 after publication. An optional `--proxy` accepts an
existing loopback HTTP proxy; it does not configure system networking. Refresh
expired credentials through the official `dart pub login` command.

New packages initially belong to their uploader. Complete each package's
publisher transfer in the authenticated pub.dev Admin page, selecting
`flyfish.dev`. Verify the result through the package's public publisher endpoint.
The upload client's credentials are not used to change publisher membership or
automated publishing permissions.

After all seven packages are available, install the hosted entry package in a
clean customer project with no overrides. Build and render its bundled examples
with external runtime requests blocked. `tool/verify-web.mjs` accepts a build
directory and an optional evidence output directory. Keep publication receipts,
registry hashes, owner checks and screenshots under `.release/pub-release/`;
never commit credentials, signed upload forms or generated caches.
