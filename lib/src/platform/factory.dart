import 'native_surface.dart'
    if (dart.library.js_interop) 'web_surface.dart'
    as platform;
import 'surface.dart';

/// Selects the native or browser surface at compile time.
FileViewerSurface createViewerSurface() => platform.createSurface();
