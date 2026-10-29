# Warm-up and lifecycle

An application-scoped runtime owns the resource host, active sessions and one idle viewer. Move startup work ahead of preview navigation while bounding retained memory.

## Application warm-up

```dart
runApp(const FileViewerHost(child: MyApp()));
```

`FileViewerHost` starts `warmUp()` after Flutter's first frame. `MyApp` is your application's root widget. The Host also observes app lifecycle changes and memory pressure.

Warm-up reports distinguish `shellReady`, `moduleReady` and `engineReady`. A ready shell or parser module does not mean every engine, font, Worker or document has been initialized, or that a document's first content is visible.

## Preload a known document

```dart
final source = FileViewerSource.asset('assets/example.pdf');

await FileViewerRuntime.instance.preload(
  source,
  theme: 'light',
  locale: 'en',
);

// Use the same source and options in a bounded layout on the next route.
final viewer = FileViewer(
  source: source,
  theme: 'light',
  locale: 'en',
);
```

Preload when you know what the user will open next. Matching source, theme and locale lets the runtime reuse that loaded session. Parsing all possible documents or engines increases CPU and memory use; it should not be a default startup step.

## Leave and reopen a route

`retainSession` defaults to true. After a preview route closes, at most one released session is retained. Reopening the same source and options reuses its document and view state. Extra idle instances are destroyed.

For sensitive documents or screens that should not retain their session:

```dart
FileViewer(
  source: source,
  retainSession: false,
)
```

Session reuse stays within the current app process. It is not a persistent cache across application restarts.

## Concurrent viewers and memory

Each simultaneously displayed viewer uses its own native View and controller. One View cannot attach to two Widgets at once; let the component manage platform attachment.

The Host releases idle instances under memory pressure. Applications can also request trimming:

```dart
await FileViewerRuntime.instance.trimMemory();
```

## Background and recovery

Backgrounding pauses current audio/video playback and retains instances while the process and OS allow it. WebView and the OS govern background rendering, Workers and timers; this preview does not implement a general rendering pause. Foregrounding requests a layout refresh, and a renderer-termination event triggers a recovery attempt. Media playback does not resume automatically; the user controls playback. The component requests neither a perpetual iOS background service nor a default Android foreground service.

The OS can suspend or terminate the entire application. After termination, provide the document source again from your application state rather than relying on an in-memory session.

## Logout and shutdown

Clear active documents and idle sessions on logout or tenant changes:

```dart
await FileViewerRuntime.instance.clearSessions();
```

If you explicitly create and own a separate runtime, call `shutdown()` at the end of its lifetime. A shut-down runtime cannot be reused. Do not shut down the global shared runtime when leaving an ordinary preview route.

Measure cold open, warmed open, route reopen and peak memory with real documents on named devices. The SDK makes no universal instant-render promise; see the [qualification matrix](https://github.com/flyfish-dev/file-viewer-flutter/blob/main/docs/qualification.md).
