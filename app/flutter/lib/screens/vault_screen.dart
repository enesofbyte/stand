import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/vault_service.dart';
import 'editor_screen.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final vault = Provider.of<VaultService>(context);
    final index = Provider.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Vault Explorer')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search content or file name...'),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: _query.isEmpty
                ? FutureBuilder<List<String>>(
                    future: vault.listPages(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final pages = snapshot.data!;
                      return ListView.builder(
                        itemCount: pages.length,
                        itemBuilder: (context, i) {
                          final item = pages[i];
                          return ListTile(
                            title: Text(item),
                            onTap: () async {
                              final content = await vault.readPage(item);
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditorScreen(path: item, initialText: content)));
                            },
                          );
                        },
                      );
                    },
                  )
                : FutureBuilder<List<Map<String, dynamic>>>(
                    future: (index as dynamic).search(_query),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final rows = snapshot.data!;
                      if (rows.isEmpty) return const Center(child: Text('No results'));
                      return ListView.builder(
                        itemCount: rows.length,
                        itemBuilder: (context, i) {
                          final r = rows[i];
                          return ListTile(
                            title: Text(r['path'] ?? ''),
                            subtitle: Text(r['excerpt'] ?? ''),
                            onTap: () async {
                              final content = await vault.readPage(r['path']);
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditorScreen(path: r['path'], initialText: content)));
                            },
                          );
                        },
                      );
                    },
                  ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final title = 'new-note-${DateTime.now().millisecondsSinceEpoch}.md';
          await vault.createPage(title, '# New note\n\nWrite here...');
          setState(() {});
        },
        child: const Icon(Icons.create_new_folder),
      ),
    );
  }
}
