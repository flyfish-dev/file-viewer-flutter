import '../source.dart';

abstract interface class ViewerResourceHost {
  Future<void> initialize();
  Uri get shellUri;
  Map<String, String> get assetBases;
  Future<Map<String, Object?>> registerSource(
    String id,
    FileViewerSource source,
  );
  Future<void> releaseSource(String id);
  Future<void> dispose();
}
