# 文件来源

使用同一个 `FileViewer` 组件显示应用资源、原生文件、内存字节或 HTTP(S) 文档。文件来源保留在 Dart 层，原生路径与鉴权头不会放入 JavaScript 桥消息。

## 应用内资源

```dart
const source = FileViewerSource.asset('assets/example.pdf');
```

在宿主应用的 `pubspec.yaml` 中声明这个文件。这是验证离线接入最直接的方式，完整步骤见[快速开始](quickstart.zh-CN.md)。

## 原生文件路径

```dart
const source = FileViewerSource.file(
  '/path/to/report.docx',
  name: 'report.docx',
);
```

由宿主应用完成文件选择和系统授权，再将可访问路径交给组件。浏览器端不能使用任意原生路径；iOS 等平台的受保护文件也需要应用先取得有效访问权限。

## 内存字节

```dart
import 'dart:typed_data';
import 'package:file_viewer_flutter/file_viewer_flutter.dart';

FileViewer fromBytes(Uint8List bytes) {
  final source = FileViewerSource.bytes(bytes, name: 'report.xlsx');
  return FileViewer(source: source);
}
```

`name` 为必填项，用真实扩展名标识格式；必要时还可以传入 `mimeType`。构造函数会复制并保护字节数据。大文件优先使用原生文件或 URL，避免额外的内存副本。

字节来源的会话匹配与字节对象身份有关。需要复用相同文档时，保留并复用同一个 `FileViewerSource`，不要在每次 `build()` 中重新复制大字节数组。

## HTTP(S) URL

```dart
final source = FileViewerSource.url(
  Uri.parse('https://your-api.example/documents/123'),
  name: 'contract.pdf',
  headers: {'Authorization': 'Bearer <your-session-token>'},
);
```

示例 URL 与令牌均为占位符，请替换成自己的接口与会话凭据。URL 构造函数接收 `Uri`，只允许 HTTP 或 HTTPS。接口没有扩展名时请设置 `name`，也可设置 `mimeType`。

原生端由本地资源层读取远程内容，鉴权头保留在 Dart；跨域跳转会剥离调用者自定义头，HTTPS 降级会被拒绝。Web 端通过浏览器获取远程数据，后端仍需正确配置 CORS。

离线资源随包分发不代表远程文档无需网络。需要离线打开远程文件时，由宿主应用完成下载、加密/缓存策略与权限检查，再使用文件或字节来源。

## 更换文档

更新 Widget 的 `source`，或在控制器就绪后调用：

```dart
await controller.load(nextSource);
```

连续切换文件时，组件通过加载代次隔离旧响应。控制器的就绪时机、错误处理与重载方法见[控制器与事件](controller.zh-CN.md)。
