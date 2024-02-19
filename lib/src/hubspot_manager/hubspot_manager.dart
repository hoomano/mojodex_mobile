import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/http_caller.dart';

import '../views/user_task_execution_list/search_bar/search_bar.dart';

enum HubspotObjectType {
  company,
  contact,
  deal,
}

extension HubspotObjectTypeName on HubspotObjectType {
  String get singularName {
    switch (this) {
      case HubspotObjectType.company:
        return 'company';
      case HubspotObjectType.contact:
        return 'contact';
      case HubspotObjectType.deal:
        return 'deal';
    }
  }

  String get pluralName {
    switch (this) {
      case HubspotObjectType.company:
        return 'companies';
      case HubspotObjectType.contact:
        return 'contacts';
      case HubspotObjectType.deal:
        return 'deals';
    }
  }
}

abstract class HubspotObject {
  HubspotObjectType get objectType;

  String name;
  String id;
  HubspotObject({required this.name, required this.id});
}

class Company extends HubspotObject {
  HubspotObjectType get objectType => HubspotObjectType.company;

  Company({required super.name, required super.id});
}

class Contact extends HubspotObject {
  HubspotObjectType get objectType => HubspotObjectType.contact;

  Contact({required super.name, required super.id});
}

class Deal extends HubspotObject {
  HubspotObjectType get objectType => HubspotObjectType.deal;

  Deal({required super.name, required super.id});
}

class HubspotFormManager with HttpCaller {
  final Logger logger = Logger('HubspotManager');

  late int producedTextVersionPk;
  HubspotFormManager({required this.producedTextVersionPk});

  static final List<String> availableEngagementTypes = [
    'notes',
    'calls',
    'emails',
    'meetings'
  ];

  HubspotObject? associatedObject;

  HubspotObjectType? selectedObjectType;

  String? engagementType = availableEngagementTypes.first;

  List<HubspotObject> _suggestions = [];
  List<HubspotObject> get suggestions => _suggestions;

  final ValueNotifier<bool> _searchingNotifier = ValueNotifier(false);
  ValueNotifier<bool> get searchingNotifier => _searchingNotifier;

  final debouncer = Debouncer(milliseconds: 500);

  Future<void> search(String query, HubspotObjectType lookupObject) async {
    debouncer.run(() async {
      _searchingNotifier.value = true;
      // Call the actual search method with the given query and
      // process the response. This might depend on your actual implementation.
      // Here I assumed it returns a list of strings.
      String params =
          "search_type=${lookupObject.pluralName}&search_string=$query";
      Map<String, dynamic>? data =
          await get(service: 'hubspot_export', params: params);
      if (data == null) {
        _suggestions = [];
        return;
      }
      if (lookupObject == HubspotObjectType.company) {
        _suggestions = data['results']
            .map<HubspotObject>((e) => Company(name: e['name'], id: e['id']))
            .toList();
      }
      if (lookupObject == HubspotObjectType.contact) {
        _suggestions = data['results']
            .map<HubspotObject>((e) => Contact(name: e['name'], id: e['id']))
            .toList();
      }
      if (lookupObject == HubspotObjectType.deal) {
        _suggestions = data['results']
            .map<HubspotObject>((e) => Deal(name: e['name'], id: e['id']))
            .toList();
      }
      _searchingNotifier.value = false;
    });
  }

  Future<bool> send() async {
    Map<String, dynamic> body = {
      'produced_text_version_pk': producedTextVersionPk,
      'associated_object_id': associatedObject?.id,
      'associated_object_type': associatedObject?.objectType.pluralName,
      'engagement_type': engagementType,
    };

    Map<String, dynamic>? data =
        await put(service: 'hubspot_export', body: body);

    return data != null;
  }
}
