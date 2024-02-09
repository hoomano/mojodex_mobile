import 'dart:io';

String replaceCharAt(String oldString, int index, String newChar) {
  return oldString.substring(0, index) +
      newChar +
      oldString.substring(index + 1);
}

Future<void> main() async {
  final dir = Directory('.');
  final List<FileSystemEntity> entities = await dir.list().toList();
  entities
      .sort((a, b) => a.path.split('./')[1].compareTo(b.path.split('./')[1]));
  var myFile = File('../src/icons.dart');
  myFile.writeAsStringSync(r"""
part of design_system;

class DesignIcon {
  DesignIcon._();

  static Widget _universalIcons(String asset,
      {double? size, Color color = Colors.white, BoxFit? fit}) {
    return Image.asset(
      "lib/DS/icons/$asset",
      color: color,
      width: size,
      fit: fit,
      height: size,
    );
  }
  """);

  for (var i = 0; i < entities.length; i++) {
    var element = entities[i];
    String name = element.path.split('./')[1];
    String className = name.replaceAll('_', '');
    className = className.replaceAll('.png', '');
    className = replaceCharAt(className, 0, className[0].toLowerCase());
    if (name == "script.dart") return;
    if (i == entities.length - 2) {
      await myFile.writeAsString("""
  static Widget $className({double? size, Color color = Colors.white, BoxFit? fit}) {
    return _universalIcons("$name", size: size, color: color, fit: fit);
  }
}
""", mode: FileMode.append);
      continue;
    }
    await myFile.writeAsString("""
  static Widget $className({double? size, Color color = Colors.white, BoxFit? fit}) {
    return _universalIcons("$name", size: size, color: color, fit: fit);
  }
""", mode: FileMode.append);
  }
}
