# Flutter SDK 交付与稳定版计划

## 目标与当前交付

独立仓库维护 Flutter API、平台适配、资源分发和设备验证，共享公共 File Viewer 渲染内核。目标平台为 Android、iOS、Web、Windows、macOS、Linux；具体已验证范围见 [兼容性矩阵](qualification.md)。开发预览版本为 `0.1.0-dev.1`，提供本地 SDK 和 pub.dev 分发；发布者为 `flyfish.dev`，在线版本以 pub.dev 注册表为准。

本地 SDK 包含入口包、四个离线资源包、macOS/WKWebView 与 Linux/CEF 适配包，以及六个平台的示例工程。SDK 内部依赖已改为本地路径；客户使用 Flutter 工具链即可接入，不需要 Node.js。约 225 MiB 前端资源随应用打包。Windows WebView2、Linux CEF 在构建时按校验锁获取并随应用安装，运行时不下载引擎。完全断网构建需事先准备 Flutter/Pub 依赖、原生构建依赖和锁定的引擎归档缓存。

## 一次配置，两处接入

通过 pub.dev 接入，在客户应用的 `pubspec.yaml` 添加：

```yaml
dependencies:
  file_viewer_flutter: 0.1.0-dev.1
```

也可以解压本地 SDK，改用路径依赖：

```yaml
dependencies:
  file_viewer_flutter:
    path: ../file_viewer_flutter-0.1.0-dev.1
```

执行一次 `flutter pub get`，再运行 `dart run file_viewer_flutter:setup --project . --apply`。可先用 `--check` 查看所需平台配置。根节点一行启动预热：

```dart
runApp(FileViewerHost(child: MyApp()));
```

在有尺寸约束的布局中，一行显示文件：

```dart
FileViewer(source: FileViewerSource.asset('assets/example.pdf'))
```

统一导入 `package:file_viewer_flutter/file_viewer_flutter.dart`。支持 asset、本地文件、bytes、HTTP(S) URL；Web 文件选择使用 bytes。客户文件由客户自己的应用声明或提供，SDK 不包含客户数据。

## 预热和复用策略

1. 应用首帧后启动共享运行时，创建资源服务并准备一个空闲预览实例，避免把初始化阻塞放在首帧前。
2. `warmUp()` 准备外壳和常用解析模块，分别报告 `shellReady`、`moduleReady`、`engineReady`。模块加载完成不等同于所有 Worker/WASM 引擎已初始化，也不等同于文件首屏已绘制。
3. 已知下一个文件时可调用 `FileViewerRuntime.instance.preload(source)`，提前解析该文件。再次打开相同来源和选项时复用文档，不重复解析。
4. 页面退出后最多保留一个空闲实例；并发页面各自租用独立实例。一个原生视图同时只归一个页面使用。
5. 内存压力回收空闲实例；后台阶段暂停当前音视频。其他后台渲染、Worker 与定时器受 WebView 和操作系统调度约束。回到前台刷新布局，收到渲染进程终止事件时尝试重建；音视频不自动恢复播放。
6. 退出账号时调用 `clearSessions()` 清除文档并撤销资源地址；自建运行时不再使用时调用 `shutdown()`。

这里的后台常驻指应用进程内的运行时保留和可恢复预热。iOS 不提供无限后台执行保证，插件也不为预览申请 Android 常驻通知服务。

## 平台实现

| 平台 | 运行容器 | 复用与分发 |
| --- | --- | --- |
| Android | 系统 WebView | headless 预热后交给 Flutter 原生视图；资源内置 |
| iOS | WKWebView | headless 预热后挂载；保留会话并处理进程回收 |
| macOS | WKWebView | 每个 Flutter 视图 ID 使用独立 NSView 容器，移动并保留内部 WebView，避免旧容器延迟销毁影响新页面 |
| Windows | WebView2 composition texture | 从预热开始使用可保留的纹理视图；固定版本引擎随构建产物安装 |
| Linux | CEF | 锁定架构与哈希的本地引擎，保留沙箱；宿主初始化通过显式配置命令完成 |
| Web | 同源 DOM | 直接运行共享渲染内核，资源同源部署，文件使用可撤销的 Blob URL |

Flutter 插件负责平台编译和依赖管理，客户不需要分别手工集成 AAR、Framework 或桌面动态库。Android/iOS 原生构建仍需对应工具链；桌面引擎完整目录及许可证必须一同分发。

## 验收阶段

| 阶段 | 交付与验收标准 |
| --- | --- |
| 本地开发预览 | 独立仓库、统一 API、离线资源、预热池、控制器、示例、配置命令和可校验 SDK；按平台记录实际通过范围 |
| 六端基础验证 | 每个目标架构完成原生构建、TXT/PDF/DOCX/XLSX/PPTX 样例、真实 Worker/WASM、连续五次页面复用、空闲预加载和关闭后重载；Windows 校验引擎签名，Linux 保持沙箱 |
| 客户设备与格式验收 | 真机 iPhone/iPad、Android WebView 新旧版本、手机/平板/桌面尺寸、触控/鼠标/键盘、移动浏览器，以及客户要求的完整格式和代表性大文件语料 |
| 生命周期与性能验收 | 后台/前台、内存压力、渲染器终止、账号退出、并发两页、主题切换、长时间重复打开；测量首屏、内存和安装体积 |
| pub.dev 发布 | 登录发布者账号，按资源包和平台适配包在先、入口包在后的顺序发布；回读注册表版本和归档校验值，再用干净客户工程从注册表安装验证 |
| 稳定版 | 设备、格式、生命周期和性能验收全部达到约定预算；补全发布记录、迁移说明和支持范围后标记稳定版 |

## 性能测量与放行标准

在命名的真机和固定文档集上使用 profile/release 构建，每个场景至少采集 30 次，分别记录冷启动、外壳已预热、文档已预加载和页面复用。记录实际文档首内容时间的 p50/p95、主线程卡顿、空闲/峰值内存、原生引擎数量和安装体积。测试框架等待时间不作为产品首屏性能。

首轮真机基线完成后，为每类设备和文件共同确定毫秒与内存预算。以下行为可以直接作为当前回归标准：

- 相同文件和选项的保留会话重开，不出现新的 `load-start` 或重复解析。
- 两个同时显示的预览使用两个独立实例；退出后空闲池不超过一个实例，内存压力清空空闲池。
- 离线样例预览不产生外部运行时 HTTP 请求，真实 Worker 和 WASM 执行成功。
- 关闭、来源切换、账号退出后不再返回旧文档内容；迟到结果不能覆盖新文档。
- 渲染进程终止后有明确错误和恢复路径，不把外壳就绪误报为文档成功。

“全部设备兼容”“所有格式瞬时首屏”需以相应证据支撑。开发预览的剩余验收项和范围持续保留在兼容性矩阵中。
