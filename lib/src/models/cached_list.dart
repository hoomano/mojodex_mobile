import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/http_caller.dart';
import 'package:mojodex_mobile/src/models/serializable_data_item.dart';
import 'package:path_provider/path_provider.dart';

abstract class CachedList<T extends SerializableDataItem> extends ChangeNotifier
    with HttpCaller {
  // Logger
  final Logger logger = Logger('CachedList');

  final String localFileName;
  final String key;
  final T Function(Map<String, dynamic>) itemFromJson;
  final String service;
  final String pkKey;
  final String nItemsKey;
  final int maxItemsInLocalFile;

  CachedList(
      {required this.localFileName,
      required this.key,
      required this.itemFromJson,
      required this.service,
      required this.pkKey,
      required this.nItemsKey,
      this.maxItemsInLocalFile = 20});

  Future<String> get _localFilePath async {
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    String dir = appDocumentsDir.path;
    return '$dir/$localFileName';
  }

  Future<File> get localFile async => File(await _localFilePath);

  bool refreshing = false;

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  int get length => items.length;

  T operator [](int index) => items[index];

  /// List of userTaskExecutions for this user
  @protected
  List<T> items = [];

  // add map()
  List<R> map<R>(R Function(T e) f) => items.map<R>(f).toList();

  // add where()
  List<T> where(bool Function(T element) test) => items.where(test).toList();

  bool loading = false;

  @protected
  Future<Map<String, dynamic>> loadListFromLocalFile() async {
    // does the local file exist?
    File file = await localFile;
    bool fileExists = await file.exists();
    if (fileExists) {
      // read the local file
      String jsonString = await file.readAsString();
      Map<String, dynamic> dataList = jsonDecode(jsonString);
      return dataList;
    } else {
      throw Exception('File does not exist');
    }
  }

  /// load the more user_task_executions
  Future<bool> loadMoreItems(
      {int maxItemsByCall = 50, required int offset}) async {
    try {
      if (loading) return false;
      loading = true;
      notifyListeners();

      Map<String, dynamic>? itemsData;
      bool loadFromBackend = true;

      // if there is no filter and offset is 0, load from local file if it exists
      if (offset == 0) {
        bool fileExists = await (await localFile).exists();
        if (fileExists) {
          itemsData = await loadListFromLocalFile();
          loadFromBackend = false;
        }
      }

      if (loadFromBackend) {
        itemsData =
            await getItems(offset: offset, maxItemsByCall: maxItemsByCall);
      }

      if (itemsData != null) {
        List<T> i = dataToItems(itemsData);
        items.addAll(i);
        if (offset == 0) {
          if (loadFromBackend) {
            writeFile(itemsData);
            logger.info("Saved to local file: $localFileName");
          } else {
            refreshLocalList();
          }
        }
      }

      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      throw Exception("Error loading items: $e");
    }
  }

  Future<void> writeFile(Map<String, dynamic> data) async {
    await (await localFile).writeAsString(jsonEncode(data));
  }

  Future<void> reloadItems({int maxItemsByCall = 50}) async {
    if (loading) return;
    items = [];
    await loadMoreItems(maxItemsByCall: maxItemsByCall, offset: 0);
  }

  /// get the list of the user_task_executions history
  /// returns a map with a single field user_task_executions which contains the list of the user_task_executions data as json
  /// or null if an error occurred
  Future<Map<String, dynamic>?> getItems(
      {int offset = 0, int maxItemsByCall = 50, int retry = 3}) async {
    try {
      String params = "$nItemsKey=$maxItemsByCall&offset=$offset";
      return await get(service: service, params: params);
    } catch (e) {
      if (e is TimeoutException && retry > 0) {
        logger.warning("getItems timeout, retrying $retry");
        return await getItems(
            offset: offset, maxItemsByCall: maxItemsByCall, retry: retry - 1);
      }
      logger.shout("Error getting items: $e");
      return null;
    }
  }

  T? getParticularItemSync(int itemPk) {
    if (!loading) {
      final item = items.firstWhereOrNull((element) => element.pk == itemPk);
      return item;
    } else {
      return null;
    }
  }

  Future<T?> getParticularItemAsync(int itemPk) async {
    T? item = getParticularItemSync(itemPk);
    if (item != null) {
      return item;
    }
    Map<String, dynamic>? data =
        await get(service: service, params: "$pkKey=$itemPk");

    if (data != null) {
      T item = itemFromJson(data);
      return item;
    } else {
      return null;
    }
  }

  FutureOr<T?> getParticularItem(int itemPk) {
    T? item = getParticularItemSync(itemPk);
    if (item != null) {
      return item;
    } else {
      return getParticularItemAsync(itemPk);
    }
  }

  Map<String, dynamic> toJson() {
    // take the first maxUserTaskExecutions userTaskExecutions
    return {
      key: items.take(maxItemsInLocalFile).map((e) => e.toJson()).toList()
    };
  }

  // Write _item in a local json file
  Future<void> saveItemsToFile() async {
    try {
      // Write the JSON string to the file
      await writeFile(toJson());
      logger.info('Data written to $localFileName successfully.');
    } catch (e) {
      logger.shout('Error writing to $localFileName: $e');
    }
  }

  void addItem(T item) {
    items.insert(0, item);
    notifyListeners();
    saveItemsToFile();
  }

  void deleteItem(T item) {
    items.remove(item);
    notifyListeners();
    saveItemsToFile();
  }

  // This function compares local user_task_executions with the ones on the server to update the local ones
  void refreshLocalList() async {
    refreshing = true;
    notifyListeners();
    Map<String, dynamic>? itemsData = await getItems();
    if (itemsData != null) {
      List<T> i = dataToItems(itemsData);
      items = i;
      saveItemsToFile();
      refreshing = false;
      notifyListeners();
    }
  }

  @protected
  List<T> dataToItems(Map<String, dynamic> itemsData) {
    return itemsData[key].map<T>((itemData) => itemFromJson(itemData)).toList();
  }

  void empty() {
    items = [];
    loading = false;
    // remove the local file
    localFile.then((file) => file.delete());
  }
}
