<p align="center">
  <a href="https://github.com/flyfish-dev/file-viewer">
    <img src="docs/assets/file-viewer.png" width="92" alt="File Viewer 品牌标识">
  </a>
</p>

<h1 align="center">File Viewer for Flutter</h1>

<p align="center">离线文档预览，一个 Flutter 组件。</p>

<p align="center">
  <a href="https://pub.dev/packages/file_viewer_flutter"><img src="https://img.shields.io/pub/v/file_viewer_flutter?include_prereleases&label=pub.dev&color=0891b2" alt="pub.dev 软件包"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-%E2%89%A5%203.47-02569B?logo=flutter" alt="Flutter 3.47 及以上"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache--2.0-64748b" alt="Apache 2.0 许可证"></a>
</p>

<p align="center">
  <a href="https://flutter.file-viewer.app/">官网</a> ·
  <a href="https://flutter.file-viewer.app/zh/docs/quickstart/">接入文档</a> ·
  <a href="https://pub.dev/packages/file_viewer_flutter">pub.dev</a> ·
  <a href="README.md">English</a>
</p>

<h3 align="center"><a href="https://github.com/flyfish-dev/file-viewer">File Viewer 主仓库 ↗</a></h3>

File Viewer for Flutter 将 [File Viewer](https://github.com/flyfish-dev/file-viewer) 的共享渲染核心接入 Flutter 应用。本仓库维护 Flutter 组件、控制器、应用生命周期、原生 WebView 适配器和离线资源包；文档渲染引擎及浏览器生态集成由主仓库维护。

> **开发预览版：`0.1.0-dev.1`。** 目标平台包括 Android、iOS、Web、Windows、macOS 与 Linux。实际构建和样例验证范围见[兼容性矩阵](docs/qualification.md)，用于生产前请验证自己的设备和业务文件集。

## 核心能力

- **统一的 Flutter API**：支持应用资产、本地路径、内存字节及带鉴权的 HTTP(S) 文件。
- **本地渲染、资源随包分发**：运行时无需公共 CDN、远程预览服务或引擎下载。
- **应用级预热与会话复用**：减少反复打开预览时的初始化工作。
- **按格式适配视图**：提供自动适配、缩放、搜索、视图状态恢复和控制器能力查询。
- **原生平台集成**：Android、iOS、macOS 使用系统 WebView，Windows 随包提供 WebView2，Linux 随包提供启用沙箱的 CEF。

## 快速开始

需要 **Flutter 3.47+ / Dart 3.13+**。仓库固定开发工具链为 Flutter `3.47.4` / Dart `3.13.3`。

### 1. 添加依赖

```yaml
dependencies:
  file_viewer_flutter: 0.1.0-dev.1
```

在应用目录安装依赖并配置原生宿主：

```sh
flutter pub get
dart run file_viewer_flutter:setup --project . --check
dart run file_viewer_flutter:setup --project . --apply
```

`--check` 预览配置差异；`--apply` 保留已有应用设置并写入必要变更。Web 无需原生宿主配置。应用原生变更后请完整重建。

### 2. 添加文档

将 PDF 放在 `assets/example.pdf`，并在应用的 `pubspec.yaml` 中声明：

```yaml
flutter:
  assets:
    - assets/example.pdf
```

### 3. 显示预览

```dart
import 'package:flutter/material.dart';
import 'package:file_viewer_flutter/file_viewer_flutter.dart';

void main() {
  runApp(const FileViewerHost(
    child: MaterialApp(
      home: Scaffold(
        body: FileViewer(
          source: FileViewerSource.asset('assets/example.pdf'),
        ),
      ),
    ),
  ));
}
```

`FileViewerHost` 在 Flutter 首帧后启动预热。`Scaffold.body` 提供有界视口；嵌入其他布局时，请使用 `Expanded` 或明确的宽高约束。

继续阅读[完整接入指南](https://flutter.file-viewer.app/zh/docs/quickstart/)。

## 开发者文档

| 文档 | 内容 |
| --- | --- |
| [平台配置](https://flutter.file-viewer.app/zh/docs/platforms/) | Android、iOS、Web、Windows、macOS 与 Linux 宿主设置 |
| [文件来源](https://flutter.file-viewer.app/zh/docs/file-sources/) | 资产、本地路径、字节、远程地址与鉴权 |
| [预热与生命周期](https://flutter.file-viewer.app/zh/docs/runtime/) | 会话复用、预加载、前后台与内存压力 |
| [控制器与事件](https://flutter.file-viewer.app/zh/docs/controller/) | 就绪事件、搜索、视图适配、缩放和错误处理 |
| [离线部署](https://flutter.file-viewer.app/zh/docs/deployment/) | 资源包、桌面引擎与本地 SDK 交付 |

## 生命周期与视图适配

在应用根部放置一个 `FileViewerHost`。宿主保留一个备用实例；退出预览后保留的会话可以在重新进入时复用原生引擎和文档。同时显示多个预览时分别使用独立原生视图，内存压力下释放空闲实例。

默认自动适配由共享渲染器按格式决定：文档适配阅读宽度，演示文稿适配画布，表格在必要时缩小以适配宽度，小表格不会被自动放大。手动缩放后，后续视口变化保留用户选择。通过 `FileViewerController` 可显式选择自动、适宽、适页或原始大小等操作。

预热初始化外壳和常用解析模块。需要提前准备指定文档时，调用 `FileViewerRuntime.instance.preload(source)`。外壳就绪、解析器预热和实际内容可见是不同状态。

进入后台会暂停音视频；WebView 和操作系统仍可能挂起或回收进程，本组件不安装永久后台服务。回到前台会请求布局刷新，渲染进程终止后会尝试恢复，媒体不会自动继续播放。退出登录时调用 `clearSessions()` 清理文档会话。

## 平台与离线分发

| 平台 | 渲染容器 | 交付方式 |
| --- | --- | --- |
| Android | 系统 WebView | 查看器资源随包分发 |
| iOS | WKWebView | 查看器资源随包分发 |
| Web | 浏览器 | 应用与查看器资源自托管 |
| macOS | 可保留的 WKWebView | 查看器资源随包分发 |
| Windows | WebView2 | 随包分发固定版本引擎并校验哈希 |
| Linux | CEF | 随包分发固定版本引擎并启用沙箱 |

渲染资源来自不可变的公开 File Viewer `3.3.0` 分发包。base、CAD、drawing、Typst 四个资源包锁定同一版本、一起安装，应用压缩前合计约 **225 MiB**。Windows 和 Linux 原生引擎会增加安装体积。客户应用仅需 Flutter 工具链，Node.js 只用于维护者构建。

构建机需要固定版本的桌面引擎归档或已填充的缓存。设置 `FILE_VIEWER_OFFLINE_BUILD=1` 后，桌面构建会在缺少缓存时直接失败，运行时不会下载引擎。远程文件、文档嵌入的外部资源、系统 WebView 与编解码器仍可能影响具体文档。

此预览版暂时隐藏打印、下载和浏览器导出控件，原生输出集成仍在验收。已验证范围及待完成事项见[兼容性矩阵](docs/qualification.md)。

## 运行示例

```sh
git clone https://github.com/flyfish-dev/file-viewer-flutter.git
cd file-viewer-flutter
flutter pub get
cd example
flutter pub get
dart run file_viewer_flutter:setup --project . --apply
flutter run
```

示例包含可离线打开的 PDF、Word、Excel、PowerPoint 和文本文件。宽窗口显示文件侧栏，紧凑布局切换为文件选择器，预览区域跟随可用宽高。

本地 SDK 交付见[离线部署](https://flutter.file-viewer.app/zh/docs/deployment/)。仓库中的依赖覆盖用于开发；正式交付的 SDK 归档会把内部依赖重写为本地路径。

## 贡献与许可证

```sh
flutter analyze
flutter test
cd runtime
npm ci
npm test
cd ..
node tool/build-runtime.mjs
python3 tool/check-pub.py
```

使用实际平台 WebView 运行受影响的集成测试。生成证据放在 `.release/`，不要提交客户文档、凭据或签名资料。架构与验收要求见[架构说明](docs/architecture.md)和[交付计划](docs/delivery-plan.zh-CN.md)。渲染问题在 [File Viewer 主仓库](https://github.com/flyfish-dev/file-viewer)维护，Flutter API 与平台集成问题提交至[本仓库 Issues](https://github.com/flyfish-dev/file-viewer-flutter/issues)。

Flutter 适配层使用 [Apache-2.0](LICENSE)。资源包与原生引擎保留各自的许可证、声明和源码获取说明，分发应用时须完整保留。macOS 适配器保留 InAppWebView 来源记录，Linux 保留 `webview_cef` 与 CEF 声明，旧 PPT 渲染器的内置水印保持不变。

品牌 Logo 沿用 [File Viewer 主项目](https://github.com/flyfish-dev/file-viewer)标识。
