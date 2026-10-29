# Publishing the package family

Publish `0.1.0-dev.2` resource and platform packages before the app-facing
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

Install the pinned scorer and require a full score from the exact entry archive:

```sh
dart pub global activate pana 0.23.19
# In the staged entry package, after its six dependencies are published:
flutter pub publish --to-archive /absolute/file_viewer_flutter.tar.gz
# From the repository:
python3 tool/check-score.py /absolute/file_viewer_flutter.tar.gz
```

The score check runs Pana with dartdoc on the archive's actual contents, without
repository overrides. The qualification workflow enforces this gate and retains
the report. Publish version-locked component packages before running the gate for
a new package-family version. Static analysis separately enforces public API
documentation on every source change. Resource rebuilds preserve package README
and changelog history; update that history explicitly for each release.

For a package-family version whose components are not published yet, dispatch
`qualify.yml` from the release branch with `compatibility_only=true` first.
This runs the real native and Web integration matrix without pretending that
unpublished hosted dependencies can be scored. Normal branch and pull-request
runs retain the full archive-scoring gate. Publish the components, score the
entry archive against their hosted versions, and then publish the entry package.

Prefer `flutter pub publish` for normal uploads. If its large-file transfer is
unreliable, `flutter pub publish --to-archive /absolute/package.tar.gz` creates a
validated archive without publishing it. `tool/upload-pub-archive.py` uses the
same [official upload protocol](https://github.com/dart-lang/pub/blob/master/lib/src/command/lish.dart)
with HTTP/2. It verifies every archive file against staging, sends OAuth only to
pub.dev, restricts storage uploads to Google's supplied endpoint, and checks the
registry archive SHA-256 after publication. An optional `--proxy` accepts an
existing loopback HTTP proxy; it does not configure system networking. Refresh
expired credentials through the official `dart pub login` command.

The qualification workflow has an optional manual base-archive transfer job
for slow local upload links. Supply only the short-lived Google Storage form
in the temporary `FILE_VIEWER_PUB_UPLOAD_FORM` repository secret. Its envelope
contains `package`, `version`, `sourceCommit` and `upload` (`url` and `fields`);
it must never contain OAuth credentials. Dispatch `qualify.yml` with
`pub_archive_transfer=true` at that exact revision. The job creates a Dart-
validated archive from public sources and uploads its bytes without finalizing
publication. Download `pub-base-transfer`, compare every archive entry with the
locally validated archive and resource manifests, then finalize locally with
`tool/upload-pub-archive.py --transfer-receipt /path/to/transfer.json` and the
downloaded archive. Delete the temporary secret after the job finishes. Keep
the callback receipt private and check registry hashes before retrying.

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
