# 预热与生命周期

应用级 Runtime 管理资源服务、活动会话与一个闲置查看器。把启动成本移到用户打开预览之前，同时控制长期保留的内存。

## 应用级预热

```dart
runApp(const FileViewerHost(child: MyApp()));
```

`FileViewerHost` 在 Flutter 首帧后启动 `warmUp()`，避免阻塞应用首帧。`MyApp` 是自己的应用根 Widget。Host 同时观察应用生命周期与内存压力。

预热报告区分 `shellReady`、`moduleReady` 和 `engineReady`。壳层或解析模块就绪，不代表每一种引擎、字体、Worker 和文档都已解析，也不代表文件首屏已呈现。

## 提前解析已知文档

```dart
final source = FileViewerSource.asset('assets/example.pdf');

await FileViewerRuntime.instance.preload(
  source,
  theme: 'light',
  locale: 'zh-CN',
);

// 在后续路由的有界布局中使用同一个来源与选项。
final viewer = FileViewer(
  source: source,
  theme: 'light',
  locale: 'zh-CN',
);
```

已知用户即将打开哪个文件时再提前加载。使用同一个来源、主题和语言，才能匹配已加载会话。预先解析全部文件或全部引擎会消耗 CPU 与内存，不应作为默认启动流程。

## 路由关闭与再次打开

`retainSession` 默认开启。退出预览路由后，最多保留一个已释放会话；再次打开同一来源与选项时复用文档与视图状态。额外闲置实例会被销毁。

敏感文档或无需保留的页面可以设置：

```dart
FileViewer(
  source: source,
  retainSession: false,
)
```

会话复用用于同一个应用进程，不等同于跨应用重启的持久缓存。

## 多个查看器与内存

同时显示的每个查看器使用独立的原生视图和控制器。同一个 View 不能同时附着在两个 Widget；请让组件负责挂载，不要自行搬运平台 View。

Host 收到内存压力时释放闲置实例。也可以由宿主主动触发：

```dart
await FileViewerRuntime.instance.trimMemory();
```

## 后台与恢复

进入后台时暂停当前音视频播放，在进程存活且系统允许时保留实例。通用渲染、Worker 和定时器的后台调度由 WebView 与操作系统决定，预览版没有通用渲染暂停机制。返回前台会触发视图尺寸更新；组件收到渲染进程终止事件时尝试重建。音视频不会自动恢复播放，由用户操作控制。组件不会申请永久 iOS 后台服务，也不会默认启动 Android 前台服务。

系统仍可能挂起或回收整个应用。应用被终止后，应从业务状态重新提供文件来源，不能依赖内存中的文档会话。

## 退出账号与销毁

退出账号或切换租户时清除活动文档和闲置会话：

```dart
await FileViewerRuntime.instance.clearSessions();
```

如果应用显式创建并拥有独立 Runtime，在彻底结束其生命周期时调用 `shutdown()`。已关闭的 Runtime 不能再次使用；不要在普通预览路由退出时关闭全局共享 Runtime。

性能预算需要在具体设备、真实文件上测量冷开、预热后打开、路由重开及内存峰值。SDK 不承诺所有文档瞬时首屏，实测范围见[兼容性矩阵](https://github.com/flyfish-dev/file-viewer-flutter/blob/main/docs/qualification.md)。
