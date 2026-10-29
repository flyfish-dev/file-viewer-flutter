import '../source.dart';

/// Resolves packaged resources and scoped document sources for a viewer surface.
abstract interface class ViewerResourceHost {
  /// Loads resource metadata and starts the platform-specific resource transport.
  Future<void> initialize();

  /// Packaged HTML entry point, available after initialization.
  Uri get shellUri;

  /// Runtime resource base URLs keyed by asset-pack identifiers.
  Map<String, String> get assetBases;

  /// Registers [source] under [id] and returns a bridge-safe source descriptor.
  Future<Map<String, Object?>> registerSource(
    String id,
    FileViewerSource source,
  );

  /// Revokes the document registration and any object URL associated with [id].
  Future<void> releaseSource(String id);

  /// Stops the transport and releases all document registrations.
  Future<void> dispose();
}
