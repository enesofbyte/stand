import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class VaultService {
  late Directory _vaultDir;
  final _uuid = const Uuid();

  Future<void> init() async {
    final appDoc = await getApplicationDocumentsDirectory();
    _vaultDir = Directory('${appDoc.path}/stand_vault');
    if (!(await _vaultDir.exists())) {
      await _vaultDir.create(recursive: true);
      // seed with a sample note
      final sample = File('${_vaultDir.path}/welcome.md');
      await sample.writeAsString('# Welcome to Stand\n\nThis is a sample note.');
    }
  }

  Directory get vaultDir => _vaultDir;

  Future<List<String>> listPages() async {
    final files = _vaultDir.listSync().whereType<File>().where((f) => f.path.endsWith('.md')).toList();
    return files.map((f) => f.path.split('/').last).toList();
  }

  Future<String> readPage(String name) async {
    final file = File('${_vaultDir.path}/$name');
    if (await file.exists()) {
      return await file.readAsString();
    }
    return '';
  }

  Future<void> writePage(String name, String content) async {
    final file = File('${_vaultDir.path}/$name');
    await file.writeAsString(content);
  }

  Future<void> createPage(String name, String content) async {
    var filename = name;
    if (!filename.endsWith('.md')) filename = '$filename.md';
    final file = File('${_vaultDir.path}/$filename');
    if (await file.exists()) {
      // add small suffix
      filename = '${_uuid.v4()}-$filename';
    }
    await File('${_vaultDir.path}/$filename').writeAsString(content);
  }
}
