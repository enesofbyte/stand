import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class IndexService {
  late Database _db;
  late Directory _vaultDir;

  Future<void> init(Directory vaultDir) async {
    _vaultDir = vaultDir;
    final dbPath = p.join(vaultDir.path, 'metadata.db');
    _db = await openDatabase(dbPath, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE notes (
          id TEXT PRIMARY KEY,
          path TEXT UNIQUE,
          title TEXT,
          excerpt TEXT,
          tags TEXT,
          aliases TEXT,
          updated_at INTEGER
        )''');
      // FTS virtual table for content indexing
      await db.execute('''
        CREATE VIRTUAL TABLE notes_fts USING fts5(path, content, tokenize = 'unicode61');
      ''');
      await db.execute('''
        CREATE TABLE backlinks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          source TEXT,
          target TEXT,
          resolved INTEGER DEFAULT 0
        )
      ''');
    });
  }

  Future<void> indexAll() async {
    final files = Directory(_vaultDir.path)
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.md'))
        .toList();
    for (final f in files) {
      final content = await f.readAsString();
      final filename = f.path.split(Platform.pathSeparator).last;
      await indexFile(filename, content);
    }
  }

  Future<void> indexFile(String pathName, String content) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final title = _extractTitle(content);
    // extract simple frontmatter tags/aliases if present
    final meta = _parseFrontmatter(content);
    final tags = (meta['tags'] is List) ? (meta['tags'] as List).join(',') : (meta['tags']?.toString() ?? '');
    final aliases = (meta['aliases'] is List) ? (meta['aliases'] as List).join(',') : (meta['aliases']?.toString() ?? '');
    await _db.insert('notes', {
      'id': pathName,
      'path': pathName,
      'title': title,
      'excerpt': _excerpt(content),
      'tags': tags,
      'aliases': aliases,
      'updated_at': now
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    await _db.insert('notes_fts', {'path': pathName, 'content': content}, conflictAlgorithm: ConflictAlgorithm.replace);

    // update backlinks for this file
    await _db.delete('backlinks', where: 'source = ?', whereArgs: [pathName]);
    final linkRe = RegExp(r"\[\[([^\]]+)\]\]");
    final matches = linkRe.allMatches(content);
    for (final m in matches) {
      final targetName = m.group(1)!.trim();
      // try to resolve target by path or by title/alias
      final res = await _db.rawQuery('SELECT path FROM notes WHERE path = ? OR title = ? OR aliases LIKE ?', [targetName, targetName, '%$targetName%']);
      final resolved = res.isNotEmpty ? 1 : 0;
      final targetPath = res.isNotEmpty ? res.first['path'] as String : targetName;
      await _db.insert('backlinks', {'source': pathName, 'target': targetPath, 'resolved': resolved});
    }
  }

  Map<String, dynamic> _parseFrontmatter(String content) {
    // naive YAML frontmatter parser — reads lines between leading '---' markers
    if (!content.startsWith('---')) return {};
    final endIdx = content.indexOf('\n---', 3);
    if (endIdx == -1) return {};
    final block = content.substring(3, endIdx).trim();
    final lines = block.split('\n');
    final Map<String, dynamic> out = {};
    for (final l in lines) {
      final kv = l.split(':');
      if (kv.length < 2) continue;
      final key = kv.first.trim();
      final rest = kv.sublist(1).join(':').trim();
      if (rest.startsWith('[') && rest.endsWith(']')) {
        // list
        final inner = rest.substring(1, rest.length - 1).split(',').map((s) => s.trim().replaceAll('\"', '')).toList();
        out[key] = inner;
      } else {
        out[key] = rest;
      }
    }
    return out;
  }

  String _extractTitle(String content) {
    final lines = content.split('\n');
    for (final l in lines) {
      final t = l.trim();
      if (t.startsWith('#')) return t.replaceFirst('#', '').trim();
    }
    return 'Untitled';
  }

  String _excerpt(String content, {int max = 160}) {
    final cleaned = content.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.length <= max) return cleaned;
    return cleaned.substring(0, max) + '...';
  }

  Future<List<Map<String, dynamic>>> search(String query) async {
    final rows = await _db.rawQuery('SELECT path, snippet(notes_fts, 1, "[[", "]]", "...", 10) as excerpt FROM notes_fts WHERE notes_fts MATCH ?', [query]);
    return rows.cast<Map<String, dynamic>>();
  }

  Future<List<String>> getBacklinksFor(String targetPath) async {
    // find rows where target matches the given path or target name
    final rows = await _db.rawQuery('SELECT source FROM backlinks WHERE target = ? OR target LIKE ?', [targetPath, '%$targetPath%']);
    return rows.map((r) => r['source'] as String).toList();
  }
}
