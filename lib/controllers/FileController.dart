import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'dart:convert' as convert;

class FileController {
  static late Directory directory;

  static Future<Directory> loadDirectory() async {
    directory = await getApplicationDocumentsDirectory();

    return directory;
  }

  static void write(String fileName, dynamic object) {
    final path = directory.path;
    final file = File('$path/$fileName');
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    file.writeAsStringSync(convert.jsonEncode(object));
  }

  static Map<String, dynamic> read(String fileName) {
    final path = directory.path;
    final file = File('$path/$fileName');
    if (!file.existsSync()) {
      return Map<String, dynamic>();
    }
    final content = file.readAsStringSync();
    return convert.jsonDecode(content);
  }
}
