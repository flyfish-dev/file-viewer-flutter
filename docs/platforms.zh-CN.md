# 平台配置

同一套 Dart API 面向六个平台，底层使用对应平台的 WebView 或 Web DOM。当前版本是开发预览，平台标签不等于覆盖所有设备、系统版本和文件格式。

## 共用配置

先完成[快速开始](quickstart.zh-CN.md)，在应用根目录预览并应用宿主配置：

```sh
dart run file_viewer_flutter:setup --project . --check
dart run file_viewer_flutter:setup --project . --apply
```

该命令只处理应用中已有的平台目录。新增平台后重新执行。可以用 `--platform android,ios,macos` 选择平台；`web` 不属于此命令的参数。

## Android

- 初始目标为 Android API 24+，使用系统 Android WebView。
- 配置命令补充 Internet 权限，以及限定到 loopback 的本地 HTTP 资源访问配置；已有自定义配置会被保留或报告需要处理的冲突。
- 无需运行独立 Android Service，无需额外申请永久后台或前台服务权限。
- 修改宿主配置后重新构建 APK。请在实际目标设备与其 WebView 版本上验证。

已有证据：小米 12 Pro / API 35 / WebView 131 上的五种自有样例、Worker/WASM、会话复用与提前加载。

## iOS

- 初始目标为 iOS 15+，使用系统 WKWebView；在 macOS 上使用 Xcode 与 Flutter iOS 工具链构建。
- 配置命令处理本地资源访问所需的 Info.plist 设置。应用的原有网络规则保持其原有意义。
- 系统可能挂起或回收后台进程，恢复行为见[预热与生命周期](runtime.zh-CN.md)。

已有证据：iPhone 17 Pro / iOS 26.4 模拟器。实体 iPhone、iPad、内存压力和更广文件集仍属于稳定版验收范围。

## Web

- 使用浏览器 DOM 与同源静态资源，不需要原生 setup 修改。
- 保留 Flutter 输出的整个 `build/web/`，包括 `assets/packages/` 与 CanvasKit/Skwasm 资源。
- 原生文件路径在浏览器不可用；文件选择器读取后使用 `FileViewerSource.bytes`。
- 带鉴权的跨域 URL 仍受浏览器 CORS 限制。

```sh
flutter build web --no-web-resources-cdn
```

已有证据：Chrome 156，JavaScript 与 Dart WASM 构建，自有五格式样例，阻断外部 HTTP 后的 Worker/WASM 实际执行。移动浏览器需要单独验证。

## macOS

- 初始目标为 macOS 12+，使用 WKWebView；使用 Xcode 与 Flutter macOS 工具链构建。
- 配置命令补充本地资源服务所需的 Info.plist 与 sandbox 网络 entitlement，保留其他设置。
- 保留 WKWebView 与文档会话时，每次 Flutter 挂载使用新的原生容器，避免同一个 View 同时挂到多个 Widget。

已有证据：Apple Silicon 实机，以及 macOS 15 的 x64 / ARM64 CI。发行应用还需要按自身分发方式完成签名、公证等流程。

## Windows

- 初始目标为 Windows 10+，使用随应用打包、带校验锁的 WebView2 Fixed Version Runtime。
- 使用 Flutter 支持的 Windows / Visual Studio C++ 构建环境；保留完整 release 输出目录与其中的浏览器运行时。
- 构建时准备固定引擎归档，应用运行时不下载安装引擎。

已有证据：Windows 2025 x64、Windows 11 ARM64 CI，真实预览与 Microsoft 运行时签名验证。其他版本仍需在目标环境验收。

## Linux

- 使用随应用打包、带校验锁的 CEF，自有适配器保留 sandbox。
- 常见构建依赖包括 clang、CMake、Ninja、pkg-config、GTK 3、ALSA、NSS、XSS 和 GBM；具体包名以目标发行版为准。
- 配置命令补充 Linux runner 的 CEF 子进程初始化与退出顺序，并设置构建连接。
- 支持非特权 user namespace 的系统可使用该 sandbox 路径；限制它的发行版需要正常的安装器为随包 `chrome-sandbox` 设置官方要求的 root 所有权与 `4755` 模式。不要在应用中静默提权或关闭 sandbox。

已有证据：Ubuntu 24.04 x64 / ARM64 CI。其他发行版、显示服务器与真实桌面视觉效果需单独验证。

## 确认你的目标环境

各平台已测内容、仍需补齐的场景与正式版门槛以仓库[兼容性矩阵](https://github.com/flyfish-dev/file-viewer-flutter/blob/main/docs/qualification.md)为准。请使用自己的目标文件、设备、内存条件与系统 WebView 测试，不把其他平台或桌面浏览器结果当成 iOS 实机证据。
