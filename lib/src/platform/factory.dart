import 'native_surface.dart'
    if (dart.library.js_interop) 'web_surface.dart'
    as platform;
import 'surface.dart';

FileViewerSurface createViewerSurface() => platform.createSurface();
