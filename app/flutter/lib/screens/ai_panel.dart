import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';

class AiPanel extends StatefulWidget {
  final String initialContext;
  const AiPanel({super.key, required this.initialContext});

  @override
  State<AiPanel> createState() => _AiPanelState();
}

class _AiPanelState extends State<AiPanel> {
  String _output = '';
  final TextEditingController _input = TextEditingController();
  bool _busy = false;

  void _askSummarize() async {
    setState(() {
      _busy = true;
      _output = '';
    });
    final ai = Provider.of<AIService>(context, listen: false);
    final summary = await ai.summarize(widget.initialContext);
    setState(() {
      _output = summary;
      _busy = false;
    });
  }

  void _extractTasks() async {
    setState(() {
      _busy = true;
      _output = '';
    });
    final ai = Provider.of<AIService>(context, listen: false);
    final tasks = await ai.extractTasks(widget.initialContext);
    setState(() {
      _output = tasks.isEmpty ? 'No tasks found' : tasks.join('\n');
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Helper')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(child: SingleChildScrollView(child: Text(widget.initialContext))),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(onPressed: _busy ? null : _askSummarize, child: const Text('Summarize')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _busy ? null : _extractTasks, child: const Text('Extract tasks')),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(controller: _input, decoration: const InputDecoration(hintText: 'Custom prompt (prototype)')),
                )
              ],
            ),
            const SizedBox(height: 12),
            if (_busy) const LinearProgressIndicator()
            else if (_output.isNotEmpty) Expanded(child: SingleChildScrollView(child: Text(_output)))
          ],
        ),
      ),
    );
  }
}
