import 'dart:convert';

import 'package:flutter/services.dart';

import '../models.dart';

const viewerAssetPackages = <String, String>{
  'base': 'file_viewer_flutter_assets',
  'cad': 'file_viewer_flutter_assets_cad',
  'drawing': 'file_viewer_flutter_assets_drawing',
  'typst': 'file_viewer_flutter_assets_typst',
};

class ViewerAssetEntry {
  const ViewerAssetEntry({
    required this.key,
    required this.contentType,
    required this.size,
    required this.sha256,
  });
  final String key;
  final String contentType;
  final int size;
  final String sha256;
}

class ViewerAssetManifest {
  ViewerAssetManifest({AssetBundle? bundle}) : bundle = bundle ?? rootBundle;

  final AssetBundle bundle;
  final entries = <String, ViewerAssetEntry>{};
  String? upstreamVersion;

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
