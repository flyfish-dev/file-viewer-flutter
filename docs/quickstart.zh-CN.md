# 快速开始

把文件预览放进 Flutter 页面。`FileViewerHost` 负责应用级预热，`FileViewer` 负责显示文件，离线资源随应用分发。

## 开始之前

使用 Flutter **3.47 或更高版本**、Dart **3.13 或更高版本**。当前发布版为 `0.1.0-dev.2`，属于开发预览；Android、iOS、Web、Windows、macOS、Linux 的实测范围见[平台配置](platforms.zh-CN.md)。维护与验收工具链为 Flutter 3.47.4 / Dart 3.13.3。

客户应用只需要 Flutter 工具链，无需 Node.js，也无需自行构建 JavaScript 内核。

## 1. 安装组件

在应用的 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  flutter:
    sdk: flutter
  file_viewer_flutter: 0.1.0-dev.2
```

```sh
flutter pub get
```

入口包会一并安装匹配版本的四个离线资源包和两个自有平台适配包。保留应用的 `pubspec.lock`，不要单独覆盖其中某个资源包的版本。

## 2. 配置宿主应用

在客户应用根目录运行一次：

```sh
dart run file_viewer_flutter:setup --project . --check
dart run file_viewer_flutter:setup --project . --apply
```

`--check` 展示差异，`--apply` 才会修改文件。命令保留已有配置，为当前存在的平台目录补充本地资源服务所需配置与平台初始化。可用 `--platform android,ios` 缩小范围。Web 不需要该命令修改配置。

完成配置后完整重建应用，原生宿主配置不能只靠 hot reload 生效。具体系统与构建要求见[平台配置](platforms.zh-CN.md)。

## 3. 准备一个文件

将自己的 PDF 放在 `assets/example.pdf`，并在同一个 `pubspec.yaml` 中声明：

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/example.pdf
```

也可以下载仓库中的[自有 PDF 示例](https://raw.githubusercontent.com/flyfish-dev/file-viewer-flutter/main/example/assets/sample.pdf)，保存为这个路径。不要把客户文件提交到公开仓库。

## 4. 显示文件

把下面内容放入 `lib/main.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:file_viewer_flutter/file_viewer_flutter.dart';

void main() {
  runApp(const FileViewerHost(child: PreviewApp()));
}

class PreviewApp extends StatelessWidget {
  const PreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Viewer Flutter',
      home: Scaffold(
        appBar: AppBar(title: const Text('文件预览')),
        body: const FileViewer(
          source: FileViewerSource.asset('assets/example.pdf'),
        ),
      ),
    );
  }
}
```

```sh
flutter run
```

`Scaffold.body` 为查看器提供有界布局。在 `Column` 内请用 `Expanded`，在其他容器内提供明确尺寸。无需为每次打开文件重新创建应用级 Host。

## 继续接入

- [文件来源](file-sources.zh-CN.md)：应用资源、原生文件、内存字节与带鉴权的 URL。
- [预热与生命周期](runtime.zh-CN.md)：提前解析、路由复用、并发与退出账号。
- [控制器与事件](controller.zh-CN.md)：就绪事件、搜索、缩放、重载与错误恢复。
- [离线与发布](deployment.zh-CN.md)：Web 静态资源、桌面引擎、体积与许可证。

如果只想运行完整示例，克隆[独立仓库](https://github.com/flyfish-dev/file-viewer-flutter)，在根目录和 `example/` 分别执行 `flutter pub get`，然后在 `example/` 执行宿主配置命令与 `flutter run`。
