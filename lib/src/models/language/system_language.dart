import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/http_caller.dart';
import 'package:mojodex_mobile/src/models/user/user.dart';
import 'package:path_provider/path_provider.dart';

class SystemLanguage extends ChangeNotifier with HttpCaller {
  final Logger logger = Logger('SystemLanguage');

  static final SystemLanguage _instance = SystemLanguage.privateConstructor();

  SystemLanguage.privateConstructor();
  factory SystemLanguage() => _instance;

  final String _localDirName = 'languages';

  Future<String> get _localDirPath async {
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    String dir = appDocumentsDir.path;
    String dirPath = '$dir/$_localDirName';
    // Create dir if it does not exist
    await Directory(dirPath).create(recursive: true);
    return dirPath;
  }

  Future<File> getLocalFile({required String languageCode}) async {
    String filePath = "${await _localDirPath}/$languageCode.json";
    return File(filePath);
  }

  // List of available languages set on Backend
  late Map<String, dynamic> availableLanguages;

  // Language json file with translations
  late Map<String, dynamic> _languageJson;

  Future<Map<String, dynamic>> _loadFromLocalFile(File file) async {
    bool fileExists = await file.exists();
    if (fileExists) {
      // read the local file
      String jsonString = await file.readAsString();
      Map<String, dynamic> data = jsonDecode(jsonString);
      return data;
    } else {
      throw Exception('File does not exist');
    }
  }

  Future<Map<String, dynamic>?> _loadFromBackend(
      {required String languageCode}) async {
    return await get(
        service: 'language',
        params: 'language_code=$languageCode',
        requestAuth: false);
  }

  void extractMapsFromData(Map<String, dynamic> data) {
    availableLanguages = data['available_languages'];
    _languageJson = data['language_json_file'];
  }

  Future<void> updateLanguage({required String languageCode}) async {
    await User().postLanguage(languageCode: languageCode);
    User().language = languageCode;
    // Whole system language
    await load(languageCode: languageCode);
    // User task and tasks execution options language
    await User().userTasksList.reloadItems();
  }

  Future<void> load({required String languageCode}) async {
    File file = await getLocalFile(languageCode: languageCode);
    bool fileExists = await file.exists();
    Map<String, dynamic>? data;
    if (fileExists) {
      data = await _loadFromLocalFile(file);
    } else {
      data = await _loadFromBackend(languageCode: languageCode);
      if (data != null) {
        _writeToFile(data, languageCode);
      }
    }
    if (data != null) {
      extractMapsFromData(data);
    } else {
      logger.shout('No data found');
    }
  }

  Future<void> refreshFromBackend({required String languageCode}) async {
    Map<String, dynamic>? data =
        await _loadFromBackend(languageCode: languageCode);
    if (data != null) {
      extractMapsFromData(data);
      notifyListeners();
      _writeToFile(data, languageCode);
    } else {
      logger.shout('No data found');
    }
  }

  Future<void> _writeToFile(
      Map<String, dynamic> data, String languageCode) async {
    File file = await getLocalFile(languageCode: languageCode);
    await file.writeAsString(jsonEncode(data));
  }

  // Returns the text corresponding to the key in the language json file,
  // nested keys are separated by a .
  String getText({required String key}) {
    List<String> keys = key.split('.');

    Map<String, dynamic> json = _languageJson;
    for (String key in keys) {
      if (json.containsKey(key)) {
        // is json[key] a Map or a String?
        if (json[key] is Map) {
          json = json[key];
        } else {
          return json[key];
        }
      } else {
        return '';
      }
    }
    return '';
  }
}
