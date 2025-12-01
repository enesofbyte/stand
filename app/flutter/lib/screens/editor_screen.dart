import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'ai_panel.dart';
import '../services/index_service.dart';
import '../services/vault_service.dart';
import '../services/task_service.dart';

class EditorScreen extends StatefulWidget {
  final String path;
  final String initialText;

  const EditorScreen({super.key, required this.path, required this.initialText});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late TextEditingController _controller;
  bool _preview = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    final vault = Provider.of<VaultService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.path),
        actions: [
          IconButton(
            icon: Icon(_preview ? Icons.edit : Icons.visibility),
            onPressed: () => setState(() => _preview = !_preview),
          ),
          IconButton(
            icon: const Icon(Icons.smart_toy),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => AiPanel(initialContext: _controller.text)));
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              await vault.writePage(widget.path, _controller.text);
              // update index if available
              final index = Provider.of(context, listen: false);
              if (index != null) {
                try {
                  await (index as dynamic).indexFile(widget.path, _controller.text);
                } catch (_) {}
              }
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.link),
            onPressed: () async {
              final index = Provider.of<IndexService>(context, listen: false);
              final list = await index.getBacklinksFor(widget.path);
              showModalBottomSheet(context: context, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [ListTile(title: const Text('Backlinks')), if (list.isEmpty) const Padding(padding: EdgeInsets.all(12), child: Text('No backlinks found')) else ...list.map((s) => ListTile(title: Text(s), leading: const Icon(Icons.note), onTap: () async { final vault = Provider.of<VaultService>(context, listen: false); final content = await vault.readPage(s); Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditorScreen(path: s, initialText: content))); })),])));

          ),
          IconButton(
            icon: const Icon(Icons.playlist_add_check),
            onPressed: () async {
              // Convert selected text to a task
              final idx = _controller.selection;
              String selected = '';
              if (idx.isValid && idx.isCollapsed == false) {
                selected = idx.textInside(_controller.text).trim();
              }
              if (selected.isEmpty) {
                // fallback – use current line
                final text = _controller.text;
                final start = text.lastIndexOf('\n', idx.start - 1);
                final end = text.indexOf('\n', idx.start);
                final lineStart = start == -1 ? 0 : start + 1;
                final lineEnd = end == -1 ? text.length : end;
                selected = text.substring(lineStart, lineEnd).trim();
              }

              if (selected.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select or place the cursor on a line with content')));
                return;
              }

              final taskService = Provider.of<TaskService>(context, listen: false);
              try {
                await taskService.createTask(title: selected);
                // replace selected / current line with markdown checkbox
                final after = '- [ ] $selected';
                if (_controller.selection.isValid && !_controller.selection.isCollapsed) {
                  final text = _controller.text;
                  final newText = text.replaceRange(_controller.selection.start, _controller.selection.end, after);
                  _controller.text = newText;
                } else {
                  // replace current line
                  final text = _controller.text;
                  final start = text.lastIndexOf('\n', _controller.selection.start - 1);
                  final end = text.indexOf('\n', _controller.selection.start);
                  final lineStart = start == -1 ? 0 : start + 1;
                  final lineEnd = end == -1 ? text.length : end;
                  final newText = text.replaceRange(lineStart, lineEnd, after);
                  _controller.text = newText;
                }
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Converted to task')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create task: $e')));
              }
            },
          ),
        ],
      ),
      body: _preview
          ? Markdown(data: _controller.text)
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,
                autofocus: true,
                keyboardType: TextInputType.multiline,
                minLines: 20,
                maxLines: null,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),
    );
  }
}
