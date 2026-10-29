import 'dart:convert';

import 'package:flutter/services.dart';

import '../models.dart';

/// Generated offline resource packages keyed by runtime asset-pack identifier.
const viewerAssetPackages = <String, String>{
  'base': 'file_viewer_flutter_assets',
  'cad': 'file_viewer_flutter_assets_cad',
  'drawing': 'file_viewer_flutter_assets_drawing',
  'typst': 'file_viewer_flutter_assets_typst',
};

/// Size, media type and digest of one packaged runtime resource.
class ViewerAssetEntry {
  /// Creates immutable metadata for the asset-bundle [key].
  const ViewerAssetEntry({
    required this.key,
    required this.contentType,
    required this.size,
    required this.sha256,
  });

  /// Flutter asset-bundle key, including its owning package.
  final String key;

  /// HTTP media type used when serving the asset to a WebView.
  final String contentType;

  /// Expected uncompressed length in bytes.
  final int size;

  /// Expected lowercase SHA-256 digest of the resource bytes.
  final String sha256;
}

/// Validates and combines resource-pack metadata for a single upstream release.
class ViewerAssetManifest {
  /// Uses [bundle] for manifest loading, defaulting to the root asset bundle.
  ViewerAssetManifest({AssetBundle? bundle}) : bundle = bundle ?? rootBundle;

  /// Bundle from which manifests and runtime resource bytes are read.
  final AssetBundle bundle;

  /// Validated entries keyed by logical runtime path after [load] completes.
  final entries = <String, ViewerAssetEntry>{};

  /// Shared public engine version, unset before metadata has loaded.
  String? upstreamVersion;

  /// Loads all manifests, checking protocol, package identity and safe paths.
  ///
  /// Resource byte digests are checked by the native host when serving assets.
  /// Throws a typed resource, compatibility or protocol failure on invalid data.
  Future<void> load() async {
    final manifests = await Future.wait(
      viewerAssetPackages.entries.map((pack) async {
        final key = 'packages/${pack.value}/assets/manifest.json';
        try {
          return (
            pack: pack,
            json: jsonDecode(
              await bundle.loadString(key),
            ) as Map<String, dynamic>,
          );
        } catch (error) {
          throw FileViewerException(
            FileViewerErrorCode.missingResources,
            'Offline resource package ${pack.value} is missing or invalid.',
            cause: error,
          );
        }
      }),
    );
    final next = <String, ViewerAssetEntry>{};
    String? version;
    for (final item in manifests) {
      final json = item.json;
      if (json['protocolVersion'] != 1 ||
          json['package'] != item.pack.value ||
          json['upstreamVersion'] is! String ||
          (version != null && version != json['upstreamVersion'])) {
        throw const FileViewerException(
          FileViewerErrorCode.incompatibleRuntime,
          'Offline resource packages must use the same upstream version and protocol.',
        );
      }
      version = json['upstreamVersion'] as String;
      for (final file in json['files'] as List<dynamic>) {
        final entry = file as Map<String, dynamic>;
        final logical = entry['path'] as String;
        if (logical.startsWith('/') ||
            logical.split('/').contains('..') ||
            next.containsKey(logical)) {
          throw const FileViewerException(
            FileViewerErrorCode.protocol,
            'Invalid or duplicate resource path.',
          );
        }
        next[logical] = ViewerAssetEntry(
          key: 'packages/${item.pack.value}/assets/$logical',
          contentType: entry['contentType'] as String,
          size: entry['size'] as int,
          sha256: entry['sha256'] as String,
        );
      }
    }
    if (!next.containsKey('index.html') || !next.containsKey('runtime.mjs')) {
      throw const FileViewerException(
        FileViewerErrorCode.missingResources,
        'The packaged viewer entry point is missing.',
      );
    }
    entries
      ..clear()
      ..addAll(next);
    upstreamVersion = version;
  }
}
