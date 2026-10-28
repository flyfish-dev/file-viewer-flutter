import 'dart:io';

import 'package:file_viewer_flutter/src/setup/configure.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.contains('--help')) {
    stdout.writeln(
      'dart run file_viewer_flutter:setup [--project PATH] [--platform android,ios,macos,linux,windows] [--check|--apply]',
    );
    return;
  }
  String? option(String name) {
    final index = arguments.indexOf(name);
    if (index >= 0) {
      if (index + 1 >= arguments.length) {
        throw ArgumentError('Missing value for $name');
      }
      return arguments[index + 1];
    }
    return arguments
        .where((item) => item.startsWith('$name='))
        .firstOrNull
        ?.substring(name.length + 1);
  }

  try {
    if (arguments.contains('--check') && arguments.contains('--apply')) {
      throw ArgumentError('Choose either --check or --apply.');
    }
    final project = Directory(option('--project') ?? Directory.current.path)
        .absolute;
    final platforms = option('--platform')?.split(',').toSet();
    final changes = await planViewerSetup(project, platforms: platforms);
    if (changes.isEmpty) {
      stdout.writeln('File Viewer host configuration is ready.');
      return;
    }
    for (final change in changes) {
      stdout.writeln(
        '${arguments.contains('--apply') ? 'Updating' : 'Would update'} ${change.relativePath}\n${change.reason}',
      );
      if (arguments.contains('--apply')) {
        final file = File('${project.path}/${change.relativePath}');
        if (await file.exists() && await file.readAsString() != change.before) {
          throw StateError(
            'File changed after inspection: ${change.relativePath}',
          );
        }
        await file.parent.create(recursive: true);
        await file.writeAsString(change.after);
      } else {
        stdout.writeln(change.after);
      }
    }
    if (!arguments.contains('--apply')) {
      stderr.writeln(
        'Review the proposed configuration, then rerun with --apply.',
      );
      exitCode = 1;
    }
  } catch (error) {
    stderr.writeln('File Viewer setup failed: $error');
    exitCode = 1;
  }
}
