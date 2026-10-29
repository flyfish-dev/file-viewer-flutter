import 'package:file_viewer_flutter/file_viewer_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const FileViewerHost(child: FileViewerExampleApp()));

const _samples = [
  (name: 'PDF', file: 'sample.pdf', icon: Icons.picture_as_pdf_outlined),
  (name: 'Word', file: 'sample.docx', icon: Icons.description_outlined),
  (name: 'Excel', file: 'sample.xlsx', icon: Icons.table_chart_outlined),
  (
    name: 'PowerPoint',
    file: 'presentation-tour.pptx',
    icon: Icons.slideshow_outlined,
  ),
  (name: 'Text', file: 'sample.txt', icon: Icons.text_snippet_outlined),
];

class FileViewerExampleApp extends StatefulWidget {
  const FileViewerExampleApp({super.key});

  @override
  State<FileViewerExampleApp> createState() => _FileViewerExampleAppState();
}

class _FileViewerExampleAppState extends State<FileViewerExampleApp> {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeData _theme(Brightness brightness) => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0C989D),
      brightness: brightness,
    ),
    visualDensity: VisualDensity.compact,
    useMaterial3: true,
  );

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'File Viewer',
    theme: _theme(Brightness.light),
    darkTheme: _theme(Brightness.dark),
    themeMode: _themeMode,
    home: ExampleHome(
      onThemeChanged: (dark) => setState(() {
        _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
      }),
    ),
  );
}

class ExampleHome extends StatefulWidget {
  const ExampleHome({super.key, required this.onThemeChanged});
  final ValueChanged<bool> onThemeChanged;

  @override
  State<ExampleHome> createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<ExampleHome> {
  final _controller = FileViewerController();
  int _selected = 0;
  bool _documentReady = false;
  bool _presenting = false;

  void _select(int index) {
    if (index == _selected) return;
    setState(() {
      _selected = index;
      _documentReady = false;
      _presenting = false;
    });
  }

  Future<void> _fit(String mode) async {
    try {
      await _controller.fit(mode: mode);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _setPresentation(bool active) async {
    try {
      await _controller.setPresentationMode(active);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _moveSlide(int delta) async {
    try {
      final state = await _controller.getViewState();
      if (state is Map && state['page'] is num) {
        await _controller.applyViewState({
          'page': (state['page'] as num).toInt() + delta,
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final sample = _samples[_selected];
    return Scaffold(
      backgroundColor: colors.surface,
      body: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () {
            if (_presenting) _setPresentation(false);
          },
          if (_presenting) ...{
            for (final key in [
              LogicalKeyboardKey.arrowRight,
              LogicalKeyboardKey.arrowDown,
              LogicalKeyboardKey.pageDown,
              LogicalKeyboardKey.space,
            ])
              SingleActivator(key): () => _moveSlide(1),
            for (final key in [
              LogicalKeyboardKey.arrowLeft,
              LogicalKeyboardKey.arrowUp,
              LogicalKeyboardKey.pageUp,
            ])
              SingleActivator(key): () => _moveSlide(-1),
          },
        },
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 880;
              return Row(
                children: [
                  if (wide) ...[
                    _FileSidebar(selected: _selected, onSelected: _select),
                    VerticalDivider(width: 1, color: colors.outlineVariant),
                  ],
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: SizedBox(
                            height: 52,
                            child: Row(
                              children: [
                                Icon(
                                  sample.icon,
                                  size: 20,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: wide
                                      ? Text(
                                          sample.file,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                      : PopupMenuButton<int>(
                                          tooltip: 'Choose document',
                                          initialValue: _selected,
                                          onSelected: _select,
                                          itemBuilder: (_) => [
                                            for (
                                              var i = 0;
                                              i < _samples.length;
                                              i++
                                            )
                                              PopupMenuItem(
                                                value: i,
                                                child: Text(_samples[i].name),
                                              ),
                                          ],
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  sample.name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              const Icon(
                                                Icons.expand_more,
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                                if (sample.file.endsWith('.pptx'))
                                  IconButton(
                                    tooltip: _presenting
                                        ? 'Exit slideshow'
                                        : 'Start slideshow',
                                    onPressed: _documentReady
                                        ? () => _setPresentation(!_presenting)
                                        : null,
                                    icon: Icon(
                                      _presenting
                                          ? Icons.close_fullscreen
                                          : Icons.slideshow_outlined,
                                      size: 20,
                                    ),
                                  ),
                                IconButton(
                                  tooltip: 'Auto fit',
                                  onPressed: _documentReady && !_presenting
                                      ? () => _fit('auto')
                                      : null,
                                  icon: const Icon(
                                    Icons.fit_screen_outlined,
                                    size: 20,
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  tooltip: 'View options',
                                  enabled: _documentReady && !_presenting,
                                  onSelected: _fit,
                                  icon: const Icon(
                                    Icons.tune_outlined,
                                    size: 20,
                                  ),
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'auto',
                                      child: Text('Auto fit'),
                                    ),
                                    PopupMenuItem(
                                      value: 'width',
                                      child: Text('Fit width'),
                                    ),
                                    PopupMenuItem(
                                      value: 'contain',
                                      child: Text('Fit page'),
                                    ),
                                    PopupMenuItem(
                                      value: 'actual',
                                      child: Text('Actual size'),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  tooltip: dark ? 'Light theme' : 'Dark theme',
                                  icon: Icon(
                                    dark
                                        ? Icons.light_mode_outlined
                                        : Icons.dark_mode_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () => widget.onThemeChanged(!dark),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 2,
                          child: _documentReady
                              ? Divider(height: 2, color: colors.outlineVariant)
                              : const LinearProgressIndicator(minHeight: 2),
                        ),
                        Expanded(
                          child: FileViewer(
                            source: FileViewerSource.asset(
                              'assets/${sample.file}',
                            ),
                            controller: _controller,
                            theme: dark ? 'dark' : 'light',
                            locale: 'en-US',
                            onEvent: (event) {
                              if (event.type == 'documentReady' && mounted) {
                                setState(() => _documentReady = true);
                              }
                              if (event.type == 'view-state-change' &&
                                  event.payload is Map) {
                                final state = (event.payload as Map)['state'];
                                final extra = state is Map
                                    ? state['extra']
                                    : null;
                                final presenting =
                                    extra is Map && extra['presenting'] == true;
                                if (mounted && _presenting != presenting) {
                                  setState(() => _presenting = presenting);
                                }
                              }
                            },
                            onError: (_) {
                              if (mounted) {
                                setState(() => _documentReady = false);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FileSidebar extends StatelessWidget {
  const _FileSidebar({required this.selected, required this.onSelected});
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: 208,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 24),
            child: Row(
              children: [
                Image.asset('assets/brand.png', width: 28, height: 28),
                const SizedBox(width: 10),
                const Text(
                  'File Viewer',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'SAMPLE DOCUMENTS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                for (var i = 0; i < _samples.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: ListTile(
                      dense: true,
                      selected: selected == i,
                      selectedTileColor: colors.primaryContainer.withValues(
                        alpha: 0.45,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      leading: Icon(_samples[i].icon, size: 20),
                      title: Text(_samples[i].name),
                      onTap: () => onSelected(i),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Local rendering\nBundled offline resources',
              style: TextStyle(
                fontSize: 11,
                height: 1.6,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
