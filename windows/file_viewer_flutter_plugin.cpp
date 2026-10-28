#include "include/file_viewer_flutter/file_viewer_flutter_plugin_c_api.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <filesystem>
#include <memory>
#include <string>

namespace file_viewer_flutter {

class RuntimePlugin : public flutter::Plugin {
 public:
  explicit RuntimePlugin(flutter::PluginRegistrarWindows* registrar) {
    channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
        registrar->messenger(), "file_viewer_flutter/runtime",
        &flutter::StandardMethodCodec::GetInstance());
    channel_->SetMethodCallHandler([](const auto& call, auto result) {
      if (call.method_name() != "getBundledRuntimePath") {
        result->NotImplemented();
        return;
      }
      std::wstring executable(32768, L'\0');
      const DWORD length = GetModuleFileNameW(nullptr, executable.data(),
                                            static_cast<DWORD>(executable.size()));
      if (length == 0 || length >= executable.size()) {
        result->Error("runtimePath", "Unable to locate the application bundle.");
        return;
      }
      executable.resize(length);
      const auto runtime = std::filesystem::path(executable).parent_path() / L"FileViewerWebView2";
      if (!std::filesystem::exists(runtime / L"msedgewebview2.exe")) {
        result->Error("runtimeMissing", "The locked offline WebView2 runtime is missing from the app bundle.");
        return;
      }
      result->Success(flutter::EncodableValue(runtime.u8string()));
    });
  }

 private:
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
};

}  // namespace file_viewer_flutter

void FileViewerFlutterPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  auto* windows_registrar = flutter::PluginRegistrarManager::GetInstance()
      ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar);
  windows_registrar->AddPlugin(std::make_unique<file_viewer_flutter::RuntimePlugin>(windows_registrar));
}

