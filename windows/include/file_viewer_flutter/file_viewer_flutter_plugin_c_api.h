#ifndef FILE_VIEWER_FLUTTER_PLUGIN_C_API_H_
#define FILE_VIEWER_FLUTTER_PLUGIN_C_API_H_

#include <flutter_plugin_registrar.h>

#ifdef FLUTTER_PLUGIN_IMPL
#define FILE_VIEWER_FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FILE_VIEWER_FLUTTER_PLUGIN_EXPORT __declspec(dllimport)
#endif

#if defined(__cplusplus)
extern "C" {
#endif

FILE_VIEWER_FLUTTER_PLUGIN_EXPORT void FileViewerFlutterPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar);

#if defined(__cplusplus)
}
#endif
#endif

