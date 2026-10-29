import 'dart:io';

import 'package:xml/xml.dart';

/// One planned, reviewable host-configuration change produced by setup.
class ViewerSetupChange {
  /// Records the original and proposed text for a project-relative file.
  const ViewerSetupChange({
    required this.relativePath,
    required this.before,
    required this.after,
    required this.reason,
  });

  /// File path relative to the selected Flutter application root.
  final String relativePath;

  /// Existing file contents, or empty text when creating a configuration file.
  final String before;

  /// Proposed complete file contents after the change.
  final String after;

  /// Human-readable explanation displayed by the setup command.
  final String reason;
}

XmlElement? _child(XmlElement parent, String name) =>
    parent.childElements.where((child) => child.name.local == name).firstOrNull;

XmlElement _plistDict(XmlElement dict, String key) {
  final children = dict.childElements.toList();
  for (var index = 0; index + 1 < children.length; index++) {
    if (children[index].name.local == 'key' &&
        children[index].innerText == key) {
      final value = children[index + 1];
      if (value.name.local != 'dict') {
        throw StateError('$key is not a plist dictionary.');
      }
      return value;
    }
  }
  final result = XmlElement(XmlName.parts('dict'));
  dict.children.addAll([
    XmlElement(XmlName.parts('key'), [], [XmlText(key)]),
    result,
  ]);
  return result;
}

void _plistBool(XmlElement dict, String key) {
  final children = dict.childElements.toList();
  for (var index = 0; index + 1 < children.length; index++) {
    if (children[index].name.local == 'key' &&
        children[index].innerText == key) {
      final existing = children[index + 1];
      if (existing.name.local == 'true') return;
      existing.replace(XmlElement(XmlName.parts('true')));
      return;
    }
  }
  dict.children.addAll([
    XmlElement(XmlName.parts('key'), [], [XmlText(key)]),
    XmlElement(XmlName.parts('true')),
  ]);
}

/// Adds local networking or sandbox network entitlements to an Apple plist.
///
/// Preserves unrelated settings and returns [source] unchanged when configured.
String configureViewerPlist(String source, {bool entitlements = false}) {
  final document = XmlDocument.parse(source);
  final dict = _child(document.rootElement, 'dict');
  if (dict == null) throw StateError('Expected a plist dictionary.');
  final before = document.toXmlString();
  if (entitlements) {
    _plistBool(dict, 'com.apple.security.network.client');
    _plistBool(dict, 'com.apple.security.network.server');
  } else {
    _plistBool(
      _plistDict(dict, 'NSAppTransportSecurity'),
      'NSAllowsLocalNetworking',
    );
  }
  return before == document.toXmlString()
      ? source
      : '${document.toXmlString(pretty: true)}\n';
}

/// Adds Android network permission and a scoped network-config reference.
///
/// Preserves an existing XML configuration reference and rejects unsupported
/// references so the setup command cannot silently overwrite another policy.
({String manifest, String configName}) configureViewerAndroidManifest(
  String source,
) {
  final document = XmlDocument.parse(source);
  final application = _child(document.rootElement, 'application');
  if (application == null) {
    throw StateError('Android manifest has no application element.');
  }
  final before = document.toXmlString();
  final internet = document.rootElement.childElements.any(
    (element) =>
        element.name.local == 'uses-permission' &&
        element.getAttribute('android:name') == 'android.permission.INTERNET',
  );
  if (!internet) {
    document.rootElement.children.insert(
      0,
      XmlElement(XmlName.parts('uses-permission'), [
        XmlAttribute(
          XmlName.parts(
            'name',
            prefix: 'android',
            namespaceUri: 'http://schemas.android.com/apk/res/android',
          ),
          'android.permission.INTERNET',
        ),
      ]),
    );
  }
  var config = application.getAttribute('android:networkSecurityConfig');
  if (config == null) {
    config = '@xml/file_viewer_network_security';
    application.setAttribute('android:networkSecurityConfig', config);
  }
  if (!RegExp(r'^@xml/[a-z0-9_]+$').hasMatch(config)) {
    throw StateError('Unsupported networkSecurityConfig reference: $config');
  }
  return (
    manifest: before == document.toXmlString()
        ? source
        : '${document.toXmlString(pretty: true)}\n',
    configName: config.substring('@xml/'.length),
  );
}

/// Allows loopback cleartext traffic while preserving existing Android rules.
///
/// Only `localhost` and `127.0.0.1` receive new exceptions. An empty [source]
/// creates a network-security configuration instead of a global exception.
String configureViewerAndroidNetwork(String source) {
  final document = XmlDocument.parse(
    source.isEmpty ? '<network-security-config/>' : source,
  );
  if (document.rootElement.name.local != 'network-security-config') {
    throw StateError('Invalid Android network security configuration.');
  }
  final before = document.toXmlString();
  for (final domain in ['localhost', '127.0.0.1']) {
    final existing = document.rootElement.childElements
        .where(
          (element) =>
              element.name.local == 'domain-config' &&
              element.getAttribute('cleartextTrafficPermitted') == 'true',
        )
        .any(
          (element) => element
              .findElements('domain')
              .any((item) => item.innerText.trim() == domain),
        );
    if (!existing) {
      document.rootElement.children.add(
        XmlElement(
          XmlName.parts('domain-config'),
          [XmlAttribute(XmlName.parts('cleartextTrafficPermitted'), 'true')],
          [
            XmlElement(
              XmlName.parts('domain'),
              [XmlAttribute(XmlName.parts('includeSubdomains'), 'false')],
              [XmlText(domain)],
            ),
          ],
        ),
      );
    }
  }
  return before == document.toXmlString()
      ? source
      : '${document.toXmlString(pretty: true)}\n';
}

String _insertOnce(
  String source,
  String marker,
  String anchor,
  String replacement,
) {
  if (source.contains(marker)) return source;
  if (anchor.allMatches(source).length != 1) {
    throw StateError(
      'Host template changed; expected exactly one integration anchor: $anchor',
    );
  }
  return source.replaceFirst(anchor, replacement);
}

/// Plans host setup changes for [directory] without writing them to disk.
///
/// Uses existing native platform directories unless [platforms] is specified.
/// Rejects unsupported templates and paths outside the selected application.
Future<List<ViewerSetupChange>> planViewerSetup(
  Directory directory, {
  Set<String>? platforms,
}) async {
  final root = await directory.resolveSymbolicLinks();
  if (!await File('$root/pubspec.yaml').exists()) {
    throw StateError(
      'Choose a Flutter application directory containing pubspec.yaml.',
    );
  }
  final changes = <ViewerSetupChange>[];
  Future<String> read(String path, {bool optional = false}) async {
    final file = File('$root/$path');
    if (!await file.exists()) {
      if (optional) return '';
      throw StateError('Missing host file: $path');
    }
    final actual = await file.resolveSymbolicLinks();
    if (!actual.startsWith('$root${Platform.pathSeparator}')) {
      throw StateError(
        'Host file escapes the selected application directory: $path',
      );
    }
    return file.readAsString();
  }

  void add(String path, String before, String after, String reason) {
    if (before != after) {
      changes.add(
        ViewerSetupChange(
          relativePath: path,
          before: before,
          after: after,
          reason: reason,
        ),
      );
    }
  }

  final selected =
      platforms ??
      {
        'android',
        'ios',
        'macos',
        'linux',
        'windows',
      }.where((platform) => Directory('$root/$platform').existsSync()).toSet();
  if (selected.any(
    (platform) =>
        !{'android', 'ios', 'macos', 'linux', 'windows'}.contains(platform),
  )) {
    throw ArgumentError('Unknown platform.');
  }
  if (selected.contains('android')) {
    const path = 'android/app/src/main/AndroidManifest.xml';
    final before = await read(path);
    final result = configureViewerAndroidManifest(before);
    add(
      path,
      before,
      result.manifest,
      'Declare network access and use a local-only cleartext exception.',
    );
    final configPath = 'android/app/src/main/res/xml/${result.configName}.xml';
    final config = await read(configPath, optional: true);
    add(
      configPath,
      config,
      configureViewerAndroidNetwork(config),
      'Allow only localhost and 127.0.0.1; preserve existing network rules.',
    );
  }
  for (final platform in ['ios', 'macos']) {
    if (!selected.contains(platform)) continue;
    final path = '$platform/Runner/Info.plist';
    final before = await read(path);
    add(
      path,
      before,
      configureViewerPlist(before),
      'Declare local resource access without a global ATS exception.',
    );
    if (platform == 'macos') {
      for (final name in ['DebugProfile', 'Release']) {
        final path = 'macos/Runner/$name.entitlements';
        final before = await read(path);
        add(
          path,
          before,
          configureViewerPlist(before, entitlements: true),
          'Allow the app sandbox to serve and read its private loopback resources.',
        );
      }
    }
  }
  if (selected.contains('linux')) {
    const include =
        '#include <file_viewer_flutter_linux/file_viewer_flutter_linux_plugin.h>';
    final runner = await File('$root/linux/runner/main.cc').exists()
        ? 'linux/runner'
        : 'linux';
    final mainPath = '$runner/main.cc';
    final main = await read(mainPath);
    var updatedMain = _insertOnce(
      main,
      include,
      '#include "my_application.h"',
      '$include\n#include "my_application.h"',
    );
    final mainAnchor = RegExp(r'int main\(int argc, char\*\* argv\)\s*\{')
        .firstMatch(updatedMain)
        ?.group(0);
    if (mainAnchor == null) {
      throw StateError('Unsupported Linux main() signature.');
    }
    updatedMain = _insertOnce(
      updatedMain,
      'initCEFProcesses(argc, argv)',
      mainAnchor,
      '$mainAnchor\n  const int cef_exit = initCEFProcesses(argc, argv);\n  if (cef_exit >= 0) return cef_exit;',
    );
    add(
      mainPath,
      main,
      updatedMain,
      'Initialize CEF subprocesses before Flutter.',
    );
    final applicationPath = '$runner/my_application.cc';
    final application = await read(applicationPath);
    var updatedApplication = _insertOnce(
      application,
      include,
      '#include "my_application.h"',
      '$include\n#include "my_application.h"',
    );
    const viewAnchor = 'FlView* view = fl_view_new(project);';
    updatedApplication = _insertOnce(
      updatedApplication,
      'G_CALLBACK(processKeyEventForCEF)',
      viewAnchor,
      '$viewAnchor\n  g_signal_connect(view, "key_press_event", G_CALLBACK(processKeyEventForCEF), nullptr);\n  g_signal_connect(view, "key_release_event", G_CALLBACK(processKeyEventForCEF), nullptr);',
    );
    add(
      applicationPath,
      application,
      updatedApplication,
      'Forward native keyboard events to the embedded CEF texture.',
    );
    const cmakePath = 'linux/CMakeLists.txt';
    final cmake = await read(cmakePath);
    const anchor = 'include(flutter/generated_plugins.cmake)';
    add(
      cmakePath,
      cmake,
      _insertOnce(
        cmake,
        'FILE_VIEWER_FLUTTER_LINUX_RUNNER_CONFIGURED',
        anchor,
        'set(FILE_VIEWER_FLUTTER_LINUX_RUNNER_CONFIGURED TRUE)\n$anchor',
      ),
      'Record the explicit Linux runner integration before loading plugins.',
    );
  }
  return changes;
}
