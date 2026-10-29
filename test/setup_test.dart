import 'package:file_viewer_flutter/src/setup/configure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

void main() {
  test('Android setup preserves existing rules and stays local-only and idempotent', () {
    const manifest =
        '<manifest xmlns:android="http://schemas.android.com/apk/res/android"><application android:networkSecurityConfig="@xml/company_network"/></manifest>';
    final configured = configureViewerAndroidManifest(manifest);
    expect(configured.configName, 'company_network');
    expect(configured.manifest, contains('android.permission.INTERNET'));
    final permission = XmlDocument.parse(configured.manifest)
        .findAllElements('uses-permission')
        .single;
    expect(
      permission.getAttribute(
        'name',
        namespaceUri: 'http://schemas.android.com/apk/res/android',
      ),
      'android.permission.INTERNET',
    );
    expect(
      configureViewerAndroidManifest(configured.manifest).manifest,
      configured.manifest,
    );
    const original =
        '<network-security-config><base-config cleartextTrafficPermitted="false"/><domain-config cleartextTrafficPermitted="false"><domain>company.test</domain></domain-config></network-security-config>';
    final network = configureViewerAndroidNetwork(original);
    final document = XmlDocument.parse(network);
    expect(
      document
          .findAllElements('base-config')
          .single
          .getAttribute('cleartextTrafficPermitted'),
      'false',
    );
    expect(
      document.findAllElements('domain').map((element) => element.innerText),
      ['company.test', 'localhost', '127.0.0.1'],
    );
    expect(configureViewerAndroidNetwork(network), network);
  });
  test('Apple setup preserves ATS restrictions and app sandbox', () {
    const plist =
        '<plist version="1.0"><dict><key>NSAppTransportSecurity</key><dict><key>NSAllowsArbitraryLoads</key><false/></dict><key>com.apple.security.app-sandbox</key><true/></dict></plist>';
    final configured = configureViewerPlist(plist);
    expect(configured, contains('NSAllowsLocalNetworking'));
    expect(configured, contains('NSAllowsArbitraryLoads'));
    expect(configured, contains('<false/>'));
    expect(configureViewerPlist(configured), configured);
    final entitlements = configureViewerPlist(plist, entitlements: true);
    expect(entitlements, contains('com.apple.security.network.server'));
    expect(entitlements, contains('com.apple.security.app-sandbox'));
    expect(
      configureViewerPlist(entitlements, entitlements: true),
      entitlements,
    );
  });
}
