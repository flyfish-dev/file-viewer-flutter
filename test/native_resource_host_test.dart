import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:file_viewer_flutter/file_viewer_flutter.dart';
import 'package:file_viewer_flutter/src/resources/manifest.dart';
import 'package:file_viewer_flutter/src/resources/native_host.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryAssets extends CachingAssetBundle {
  final files = <String, Uint8List>{};
  MemoryAssets() {
    for (final pack in viewerAssetPackages.entries) {
      final resources = pack.key == 'base'
          ? {
              'index.html': (content: '<!doctype html>', type: 'text/html'),
              'runtime.mjs': (
                content: 'export const ready = true;',
                type: 'text/javascript',
              ),
            }
          : <String, ({String content, String type})>{};
      final entries = <Map<String, Object?>>[];
      for (final entry in resources.entries) {
        final bytes = Uint8List.fromList(utf8.encode(entry.value.content));
        files['packages/${pack.value}/assets/${entry.key}'] = bytes;
        entries.add({
          'path': entry.key,
          'size': bytes.length,
          'contentType': entry.value.type,
          'sha256': sha256.convert(bytes).toString(),
        });
      }
      files['packages/${pack.value}/assets/manifest.json'] = Uint8List.fromList(
        utf8.encode(
          jsonEncode({
            'protocolVersion': 1,
            'package': pack.value,
            'upstreamVersion': 'fixture',
            'files': entries,
          }),
        ),
      );
    }
  }
  @override
  Future<ByteData> load(String key) async {
    final data = files[key];
    if (data == null) throw StateError('Missing test asset');
    return ByteData.sublistView(data);
  }
}

Future<({int status, Map<String, String> headers, List<int> bytes})> request(
  HttpClient client,
  Uri uri, {
  String method = 'GET',
  Map<String, String> headers = const {},
}) async {
  final request = await client.openUrl(method, uri);
  headers.forEach(request.headers.set);
  final response = await request.close();
  final resultHeaders = <String, String>{};
  response.headers.forEach((name, values) {
    resultHeaders[name] = values.join(',');
  });
  final bytes = await response.fold<List<int>>(
    [],
    (buffer, chunk) => buffer..addAll(chunk),
  );
  return (status: response.statusCode, headers: resultHeaders, bytes: bytes);
}

void main() {
  test('resource host restricts origin/token and supports document Range/HEAD/revocation', () async {
    final host = NativeViewerResourceHost(bundle: MemoryAssets());
    final client = HttpClient()..autoUncompress = false;
    addTearDown(() async {
      client.close(force: true);
      await host.dispose();
    });
    await host.initialize();
    final shell = await request(client, host.shellUri);
    expect(shell.status, 200);
    expect(shell.headers['content-type'], startsWith('text/html'));
    expect(
      (await request(
        client,
        host.shellUri,
        headers: {'origin': 'https://outside.test'},
      )).status,
      403,
    );
    expect(
      (await request(
        client,
        host.shellUri.replace(path: '/wrong/assets/index.html'),
      )).status,
      404,
    );
    final input = await host.registerSource(
      'document',
      FileViewerSource.bytes(
        Uint8List.fromList(List.generate(10, (index) => index)),
        name: 'data.bin',
      ),
    );
    final uri = Uri.parse(input['url']! as String);
    final slice = await request(client, uri, headers: {'range': 'bytes=2-5'});
    expect(slice.status, 206);
    expect(slice.bytes, [2, 3, 4, 5]);
    expect(slice.headers['content-range'], 'bytes 2-5/10');
    final head = await request(client, uri, method: 'HEAD');
    expect(head.status, 200);
    expect(head.bytes, isEmpty);
    expect(head.headers['content-length'], '10');
    expect(
      (await request(client, uri, headers: {'range': 'bytes=99-'})).status,
      416,
    );
    await host.releaseSource('document');
    expect((await request(client, uri)).status, 404);
  });

  test(
    'proxy preserves encoded byte length and encoding without truncating gzip',
    () async {
      final upstream = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final plain = utf8.encode(
        'A remote file whose gzip body has a different length.',
      );
      final compressed = gzip.encode(plain);
      upstream.listen((request) async {
        request.response.headers.set(HttpHeaders.contentEncodingHeader, 'gzip');
        request.response.contentLength = compressed.length;
        request.response.add(compressed);
        await request.response.close();
      });
      final host = NativeViewerResourceHost(bundle: MemoryAssets());
      final client = HttpClient()..autoUncompress = false;
      addTearDown(() async {
        client.close(force: true);
        await host.dispose();
        await upstream.close(force: true);
      });
      await host.initialize();
      final input = await host.registerSource(
        'remote',
        FileViewerSource.url(
          Uri.parse('http://127.0.0.1:${upstream.port}/file'),
        ),
      );
      final result = await request(client, Uri.parse(input['url']! as String));
      expect(result.status, 200);
      expect(result.headers['content-encoding'], 'gzip');
      expect(result.headers['content-length'], '${compressed.length}');
      expect(gzip.decode(result.bytes), plain);
    },
  );

  test('source names never expose native directory paths', () {
    expect(
      const FileViewerSource.file('/private/customer/report#1.pdf').filename,
      'report#1.pdf',
    );
    expect(
      const FileViewerSource.file('C:\\private\\report.pdf').filename,
      'report.pdf',
    );
    expect(
      FileViewerSource.url(
        Uri.parse('https://files.test/report%20one.pdf?token=private'),
      ).filename,
      'report one.pdf',
    );
  });
}
