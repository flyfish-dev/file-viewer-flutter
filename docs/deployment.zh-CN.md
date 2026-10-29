# 离线与发布

渲染内核、Worker、WASM、字体与第三方资产随 Flutter 资源包分发。预览在设备本地完成，无需额外的文档转码服务。

## 分发内容与体积

`file_viewer_flutter` 锁定安装 base、CAD、drawing、Typst 四个资源包，以及 Linux 与 macOS 自有适配包。当前资源约为 225 MiB，属于应用压缩之前的资源量；它不是所有平台最终安装包大小。

客户不需要安装 npm 包或执行 JavaScript copy-assets。不要删除资源目录、拆散版本匹配关系，也不要在生产环境用公网 CDN 补齐缺失的离线资源。体积评估应以自己的目标平台 release 构建为准。

## Web 静态部署

```sh
flutter build web --no-web-resources-cdn
```

将整个 `build/web/` 部署到静态托管平台。不要只上传 `index.html` 与主 Dart JavaScript 文件：包内 HTML、JS、Worker、WASM、字体与清单同样需要保留。

使用 `application/wasm` 提供 WASM 文件，JS 返回正确 JavaScript MIME，不要让 SPA fallback 将缺失的资源返回成 HTML。不要把包含 Blob 或本地预览的同源内容用不兼容的 CSP 拦截；具体部署策略应以实际资源请求、浏览器控制台与组织要求为准，不建议照搬全站放开的策略。

首次验证推荐在网络面板确认本地资源均来自同源，再阻断外部请求打开自有样例。带远程图片、远程文件来源或外部链接的业务文档仍可能使用网络。

## Windows 与 Linux 引擎

Windows 打包校验锁定的 WebView2 Fixed Version Runtime，Linux 打包校验锁定的 CEF。构建机需要对应平台、架构的固定归档或已填充缓存。构建脚本先校验 SHA-256 再解压；运行时不下载引擎。

需要缓存限定的构建时，预先准备已经验证的引擎缓存，并设置 `FILE_VIEWER_OFFLINE_BUILD=1`；归档缺失时构建会失败。Linux sandbox 要求见[平台配置](platforms.zh-CN.md)。

Android、iOS、macOS 使用系统提供的 WebView，系统引擎与字体、编解码能力仍会影响兼容性。

## 本地 SDK 与隔离环境

完整本地 SDK 归档会把内部包依赖改写为相对路径，可用于无法访问 pub.dev 的交付环境。它不同于直接从 GitHub 下载单个根包源码；单独复制根包不会携带完整离线资源和平台适配包。

需要在隔离环境构建时，还应预置 Flutter SDK、所有 Dart 依赖、平台工具链及 Windows/Linux 引擎缓存。运行时离线与构建环境完全离线是两项不同验收。

## 升级与生产验收

当前版本为 `0.1.0-dev.1` 开发预览。一起升级整个包族，保留锁文件，重新运行宿主配置差异预览，并在目标设备回归文件首屏、搜索缩放、路由重开、后台恢复与内存压力。

稳定版仍需要实体 iOS、更多设备/系统与代表性文件集、生命周期和性能预算等验收。最新范围见[兼容性矩阵](https://github.com/flyfish-dev/file-viewer-flutter/blob/main/docs/qualification.md)。

## 许可证与归属

适配层使用 Apache-2.0。保留所有资源包中的上游 LICENSE、NOTICE、授权台账、source offer 和平台运行时许可证。macOS 派生适配器、Linux CEF 与 Windows 引擎保留各自上游条款。

旧 PPT 渲染器的内置水印会保留，不提供绕过水印的接入方式。各文件格式的使用条件以随包许可证和相应授权为准。使用安全要求较高的文档时，由宿主应用管理文件选择、存储、权限与退出账号清理。
