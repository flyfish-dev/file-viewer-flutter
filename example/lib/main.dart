import 'package:file_viewer_flutter/file_viewer_flutter.dart';
import 'package:flutter/material.dart';

void main() => runApp(const FileViewerHost(child: FileViewerExampleApp()));

class FileViewerExampleApp extends StatelessWidget {
  const FileViewerExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'File Viewer',
    theme: ThemeData(
      colorSchemeSeed: const Color(0xFF16845B),
      useMaterial3: true,
    ),
    home: const ExampleHome(),
  );
}

class ExampleHome extends StatelessWidget {
  const ExampleHome({super.key});

  @override
  Widget build(BuildContext context) {
    const samples = [
      (name: 'PDF', file: 'sample.pdf', icon: Icons.picture_as_pdf_outlined),
      (name: 'Word', file: 'sample.docx', icon: Icons.description_outlined),
      (name: 'Excel', file: 'sample.xlsx', icon: Icons.table_chart_outlined),
      (name: 'PowerPoint', file: 'sample.pptx', icon: Icons.slideshow_outlined),
      (name: 'Text', file: 'sample.txt', icon: Icons.text_snippet_outlined),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('File Viewer')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Open a document',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'These bundled samples work offline. The viewer prepares in the background while you choose a file.',
                ),
                const SizedBox(height: 20),
                for (final sample in samples)
                  Card(
                    child: ListTile(
                      leading: Icon(sample.icon),
                      title: Text(sample.name),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ExamplePreview(
                            filename: sample.file,
                            title: sample.name,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExamplePreview extends StatefulWidget {
  const ExamplePreview({
    super.key,
    required this.filename,
    required this.title,
  });
  final String filename;
  final String title;
  @override
  State<ExamplePreview> createState() => _ExamplePreviewState();
}

class _ExamplePreviewState extends State<ExamplePreview> {
  final _controller = FileViewerController();
  bool _dark = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
      actions: [
        IconButton(
          tooltip: 'Fit width',
          icon: const Icon(Icons.fit_screen),
          onPressed: () {
            if (_controller.isAttached) _controller.fit();
          },
        ),
        IconButton(
          tooltip: 'Theme',
          icon: Icon(
            _dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
          onPressed: () => setState(() {
            _dark = !_dark;
          }),
        ),
      ],
    ),
    body: SafeArea(
      child: FileViewer(
        source: FileViewerSource.asset('assets/${widget.filename}'),
        controller: _controller,
        theme: _dark ? 'dark' : 'light',
      ),
    ),
  );
}
