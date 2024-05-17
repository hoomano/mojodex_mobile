import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/http_caller.dart';
import 'package:mojodex_mobile/src/models/language/system_language.dart';
import 'package:mojodex_mobile/src/models/session/socketio_connector.dart';
import 'package:mojodex_mobile/src/models/user/company.dart';
import 'package:mojodex_mobile/src/models/user/goal.dart';
import 'package:mojodex_mobile/src/models/user/user_shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import '../../microphone.dart';
import '../../purchase_manager/purchase_manager.dart';
import '../calendar_manager/calendar_manager.dart';
import '../status_bar/calendar_suggestion.dart';
import '../tasks/user_task_executions_history.dart';
import '../tasks/user_tasks_list.dart';
import '../todos/todo-list.dart';

/// This class is a Singleton representing the logged User
class User extends ChangeNotifier with HttpCaller {
  final PurchaseManager purchaseManager = PurchaseManager();

  // Logger
  final Logger logger = Logger('User');

  // Unique instance of the class
  static final User _instance = User.privateConstructor();

  // Private constructor of the class, called once when the class is created
  User.privateConstructor();

  factory User() => _instance;

  // Shared preferences
  late UserSharedPreferences _sharedPreferences;
  bool _sharedPreferencesInitialized = false;

  // Path to application documents directory
  late String appDocPath;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  late Company? company;
  late Goal? goal;

  Future<void> _initializeSharedPreferences() async {
    if (_sharedPreferencesInitialized) return;
    _sharedPreferences = await UserSharedPreferences.create();
    _sharedPreferencesInitialized = true;
  }

  /// Function to log user in with existing token
  Future<void> login() async {
    try {
      await _initializeSharedPreferences();
      logger.fine("👉 login started");
      if (tokenBackendPython == null) {
        return;
      }

      // This is the first call method that will determine if user is logged in or not
      Map<String, dynamic>? response = await postTimezoneOffset();
      if (response == null) {
        // token expired, user should re sign-in
        return;
      }

      // If disconnected during a session, reconnect socket
      SocketioConnector().reconnect();
      List<Future> futures = [
        SystemLanguage().load(languageCode: language!),
        Microphone().init(),
      ];
      await Future.wait(futures);
      if (User().hasAlreadyDoneTask) {
        CalendarSuggestion().init();
      }

      purchaseManager.init().then((value) {
        //purchaseManager.init() also runs userTasksList.loadMoreItems(offset: 0)
        userTaskExecutionsHistory.loadMoreItems(offset: 0).then((value) {
          todoList.loadMoreItems(offset: 0);
        });
      });

      SystemLanguage().refreshFromBackend(languageCode: language!);

      Directory appDocDir = await getApplicationDocumentsDirectory();
      appDocPath = appDocDir.path;

      // Onboarding
      final result = getOnboardingPresented(); // This returns a FutureOr<bool>
      bool presented = result is Future<bool> ? await result : result;
      if (!presented) {
        await purchaseManager.getProductCategories();
      } else {
        //await HomeChat().init();
      }
      _isLoggedIn = true;
      notifyListeners();

      logger.fine("👉 login done");
    } on Exception catch (e) {
      throw e;
    }
  }

  void _fillSharedPreferences({
    required String token,
    required String name,
    required bool termsAndConditionsAgreed,
    String? languageCode,
  }) {
    _sharedPreferences.tokenBackendPython = token;
    _sharedPreferences.name = name;
    _sharedPreferences.profilePicture =
        null; // null for now with no use of providers
    _sharedPreferences.agreeTermsConditions = termsAndConditionsAgreed;
    if (languageCode != null) {
      _sharedPreferences.language = languageCode;
    } else {
      postLanguage();
    }
  }

  /// Function to log user out
  /// Clears SharePreferences instance
  /// Clears user tasks
  void logout() {
    _sharedPreferences.clearSharedPreferences();
    _userTasksList.empty();
    _userTaskExecutionsHistory.empty();
    _todoList.empty();
    CalendarManager().resetPermission();
    _isLoggedIn = false;

    notifyListeners();
  }

  Future<void> _userDataToSharedPreferences(
      Map<String, dynamic> userData) async {
    String token = userData['token'];
    String name = userData['name'];
    bool termsAndConditionsAgreed = userData['terms_and_conditions_agreed'];
    String? languageCode = userData['language_code'];
    await _initializeSharedPreferences();
    _fillSharedPreferences(
        token: token,
        name: name,
        termsAndConditionsAgreed: termsAndConditionsAgreed,
        languageCode: languageCode);
  }

  Future<Map<String, dynamic>?> signUp(
      String name, String email, String password) async {
    Map<String, dynamic>? userData = await put(
        service: 'user',
        body: {'name': name, 'email': email, 'password': password},
        authenticated: false,
        returnError: true,
        silentError: true // specific management
        );
    if (userData == null) return null;
    if (userData.containsKey('error')) {
      return userData;
    }
    await _userDataToSharedPreferences(userData);
    return userData;
  }

  Future<Map<String, dynamic>?> signInWithEmail(
      String email, String password) async {
    Map<String, dynamic>? userData = await post(
        service: 'user',
        body: {
          'email': email,
          'password': password,
          'login_method': 'email_password'
        },
        authenticated: false,
        returnError: true,
        silentError: true // specific management
        );
    if (userData == null) return null;
    if (userData.containsKey('error')) {
      return userData;
    }
    await _userDataToSharedPreferences(userData);
    return userData;
  }

  Future<Map<String, dynamic>?> signInWithGoogle(
      String email, String token) async {
    Map<String, dynamic>? userData = await post(
        service: 'user',
        body: {'email': email, 'google_token': token, 'login_method': 'google'},
        authenticated: false,
        returnError: true,
        silentError: true // specific management
        );
    if (userData == null) return null;
    if (userData.containsKey('error')) {
      return userData;
    }
    await _userDataToSharedPreferences(userData);
    return userData;
  }

  Future<bool> setTermsAndConditions() async {
    Map<String, dynamic>? success = await acceptTermsAndConditions();
    if (success != null) {
      _sharedPreferences.agreeTermsConditions = true;
      return true;
    }
    return false;
  }

  FutureOr<bool> getOnboardingPresented() async {
    if (onboardingPresented) return true;
    Map<String, dynamic>? success =
        await get(service: 'onboarding', params: '');
    onboardingPresented = success?["onboarding_presented"] ?? false;
    return onboardingPresented;
  }

  Future<bool> setOnboardingPresented() async {
    onboardingPresented = true;
    Map<String, dynamic>? success = await put(service: 'onboarding', body: {});
    return success != null;
  }

  Future<Map<String, dynamic>?> postTimezoneOffset() async {
    return await post(service: 'timezone', body: {
      "timezone_offset": "${-DateTime.now().timeZoneOffset.inMinutes}"
    });
  }

  Future<Map<String, dynamic>?> postLanguage({String? languageCode}) async {
    String languageCodeToSet = languageCode ??
        _sharedPreferences.language ??
        Platform.localeName.toLocale().languageCode;
    language = languageCodeToSet;

    Map<String, dynamic>? response = await post(
        service: 'language', body: {'language_code': languageCodeToSet});

    return response;
  }

  Future<Map<String, dynamic>?> acceptTermsAndConditions() async {
    Map<String, dynamic>? response =
        await put(service: 'terms_and_conditions', body: {});
    /* if (response != null) {
      await HomeChat().init();
    }*/
    return response;
  }

  /// List of userTasks for this user
  UserTasksList _userTasksList = UserTasksList();
  UserTasksList get userTasksList => _userTasksList;

  final TodoList _todoList = TodoList();
  TodoList get todoList => _todoList;

  final UserTaskExecutionsHistory _userTaskExecutionsHistory =
      UserTaskExecutionsHistory();
  UserTaskExecutionsHistory get userTaskExecutionsHistory =>
      _userTaskExecutionsHistory;

  Future<Map<String, dynamic>?> putDevice({required String fcmToken}) async {
    return await put(service: 'device', body: {'fcm_token': fcmToken});
  }

  Future<bool> resetPassword({required token, required newPassword}) async {
    var response =
        await client.post(Uri.parse("${dotenv.env['BACKEND_URI']}/password"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'Authorization': token,
              'new_password': newPassword,
              'datetime': DateTime.now().toIso8601String()
            }));
    return response.statusCode == 200;
  }

  Future<void> deleteAccount() async {
    logger.shout("Delete account not implemented yet");
  }

  String? get profilePicture => _sharedPreferences.profilePicture;
  void onProfilePictureError() {
    _sharedPreferences.profilePicture = null;
  }

  String? get themeMode => _sharedPreferences.themeMode;
  set themeMode(String? themeMode) => _sharedPreferences.themeMode = themeMode;
  String? get name => _sharedPreferences.name;
  bool get agreeTermsConditions => _sharedPreferences.agreeTermsConditions;
  bool? get notifAllowed => _sharedPreferences.notifAllowed;
  set notifAllowed(bool? notifAllowed) =>
      _sharedPreferences.notifAllowed = notifAllowed;
  String? get fcmToken => _sharedPreferences.fcmToken;
  set fcmToken(String? fcmToken) => _sharedPreferences.fcmToken = fcmToken;
  String? get language => _sharedPreferences.language;
  set language(String? language) => _sharedPreferences.language = language;
  String? get tokenBackendPython => _sharedPreferences.tokenBackendPython;
  List<String>? get authorizedCalendarIds =>
      _sharedPreferences.authorizedCalendarsId;
  set authorizedCalendarIds(List<String>? authorizedCalendarIds) =>
      _sharedPreferences.authorizedCalendarsId = authorizedCalendarIds;
  bool get vocalMessageAutoPlay => _sharedPreferences.vocalMessageAutoPlay;
  set vocalMessageAutoPlay(bool vocalMessageAutoPlay) =>
      _sharedPreferences.vocalMessageAutoPlay = vocalMessageAutoPlay;
  bool get askedForCalendarAccessOnce =>
      _sharedPreferences.askedForCalendarAccessOnce;
  set askedForCalendarAccessOnce(bool askedForCalendarAccessOnce) =>
      _sharedPreferences.askedForCalendarAccessOnce =
          askedForCalendarAccessOnce;
  bool get hasAlreadyDoneTask => _sharedPreferences.hasAlreadyDoneTask;
  set hasAlreadyDoneTask(bool hasAlreadyDoneTask) =>
      _sharedPreferences.hasAlreadyDoneTask = hasAlreadyDoneTask;
  bool get onboardingPresented => _sharedPreferences.onboardingPresented;
  set onboardingPresented(bool onboardingPresented) =>
      _sharedPreferences.onboardingPresented = onboardingPresented;
}
