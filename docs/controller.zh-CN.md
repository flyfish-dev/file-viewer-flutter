# 控制器与事件

`FileViewerController` 提供统一的文档、搜索、缩放与视图命令。每个同时显示的查看器使用一个独立控制器，并在其所属页面销毁时释放控制器。

## 就绪后再执行命令

下面是可直接作为页面使用的完整示例：

```dart
import 'package:flutter/material.dart';
import 'package:file_viewer_flutter/file_viewer_flutter.dart';

class ControlledPreview extends StatefulWidget {
  const ControlledPreview({super.key});

  @override
  State<ControlledPreview> createState() => _ControlledPreviewState();
}

class _ControlledPreviewState extends State<ControlledPreview> {
  final controller = FileViewerController();
  bool documentReady = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('文件预览'),
        actions: [
          IconButton(
            tooltip: '放大',
            onPressed: documentReady ? () async {
              await controller.zoomIn();
            } : null,
            icon: const Icon(Icons.zoom_in),
          ),
        ],
      ),
      body: FileViewer(
        source: const FileViewerSource.asset('assets/example.pdf'),
        controller: controller,
        onEvent: (event) {
          if (event.type == 'documentReady' && mounted) {
            setState(() => documentReady = true);
          }
        },
        onError: (error) {
          if (mounted) setState(() => documentReady = false);
          debugPrint(error.toString());
        },
      ),
    );
  }
}
```

`ready` 表示控制器已绑定到原生视图；`documentReady` 表示本轮文档加载完成。统计可见首屏时仍需单独测量真实内容绘制，不能把这两个事件直接当作屏幕首帧。

## 常用命令

| 目标 | 方法 |
| --- | --- |
| 更换文件 | `load(source)` |
| 重载当前文件 | `reload()` |
| 搜索、清除搜索 | `search(query)`、`clearSearch()` |
| 下一个 / 上一个结果 | `nextSearchResult()`、`previousSearchResult()` |
| 放大、缩小、重置 | `zoomIn()`、`zoomOut()`、`resetZoom()` |
| 适宽 / 适页 | `fit(mode: 'width')`、`fit(mode: 'contain')` |
| 读取 / 恢复视图状态 | `getViewState()`、`applyViewState(state)` |
| 查询可用操作 | `getCapabilities()` |
| 清除当前文档 | `close()` |

不同格式的可用操作不同。先用 `getCapabilities()` 查询实际可用项，再向用户显示对应业务操作；搜索、缩放等命令不代表每个格式具有相同能力。开发预览版的打印、下载与浏览器导出 UI 仍处于宿主原生输出接入验收阶段。

## 错误与恢复

`onError` 接收加载或初始化错误。`FileViewerException.code` 区分 `missingResources`、`unsupportedSource`、`sourceUnavailable`、`loadFailed` 等情况，`cause` 可携带底层原因。不要把包含用户令牌的完整 URL 或鉴权头写入日志。

默认错误界面提供 Retry。需要自定义时使用 `errorBuilder(context, error, retry)`，调用提供的 `retry()` 可重新创建失败的查看器。运行时也会在收到原生渲染进程终止事件后尝试恢复。

主动切换文档前应将页面中自己的“文档已就绪”状态重置为 false，再等待新一轮 `documentReady`；关闭或销毁后不要继续发送控制器命令。
