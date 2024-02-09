import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This class is an attribute of the user
/// to store some data in the shared preferences

class UserSharedPreferences {
  // Logger
  final Logger logger = Logger('UserSharedPreference');

  late SharedPreferences _preferences;

  /// Private synchronous constructor of UserSharedPreference
  UserSharedPreferences._create({required SharedPreferences preferences}) {
    _preferences = preferences;
  }

  /// Async constructor of UserSharedPreference
  static Future<UserSharedPreferences> create() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var instance = UserSharedPreferences._create(preferences: preferences);
    return instance;
  }

  /// shared preferences keys
  /// use to store some information permanently
  final String _keyProfilePicture = "profilePicture";
  final String _keyThemeMode = "themeMode";
  final String _keyTokenBackendPython = "pythonBackendToken";
  final String _keyName = "name";
  final String _keyAgreeTermsConditions = "agreeTermsConditions";
  final String _keyIntroDone = "introDone";
  final String _keyNotifAllowed = "notifAllowed";
  final String _keyFcmToken = "fcmToken";
  final String _keyLanguage = "language";
  final String _keyAuthorizedCalendars = "calendars";
  final String _keyVocalMessageAutoPlay = "vocalMessageAutoPlay";
  final String _keyAskedForCalendarAccessOnce = "askedForCalendarAccessOnce";
  final String _keyHasAlreadyDoneTask = "hasAlreadyDoneTask";
  final String _keyOnboardingPresented = "onboardingPresented";

  /// profile picture [profilePicture] setter
  /// to store the value in the shared preferences
  set profilePicture(String? picture) {
    logger.finest("set profilePicture: $picture");
    _setSharedPreferenceString(_keyProfilePicture, picture);
  }

  /// profile picture [profilePicture] getter
  /// to get the value from the shared preferences
  String? get profilePicture {
    return _preferences.getString(_keyProfilePicture);
  }

  /// theme mode [themeMode] setter
  /// to store the value in the shared preferences
  set themeMode(String? themeMode) {
    //logger.finest("set themeMode: $themeMode");
    _setSharedPreferenceString(_keyThemeMode, themeMode);
  }

  /// theme mode [themeMode] getter
  /// to get the value from the shared preferences
  String? get themeMode {
    return _preferences.getString(_keyThemeMode);
  }

  /// token [name] setter
  set name(String? name) {
    logger.finest("set name: $name");
    _setSharedPreferenceString(_keyName, name);
  }

  /// token [name] getter
  /// to get the value from the shared preferences
  String? get name {
    return _preferences.getString(_keyName);
  }

  /// token [tokenBackendPython] setter
  /// to store the value in the shared preferences
  set tokenBackendPython(String? newToken) {
    logger.finest("set tokenBackendPython: $newToken");
    _setSharedPreferenceString(_keyTokenBackendPython, newToken);
  }

  /// token [tokenBackendPython] getter
  /// to get the value from the shared preferences
  String? get tokenBackendPython {
    return _preferences.getString(_keyTokenBackendPython);
  }

  /// agree terms and conditions [agreeTermsConditions] setter
  /// to store the value in the shared preferences
  set agreeTermsConditions(bool agree) {
    logger.finest("set agreeTermsConditions: $agree");
    _setSharedPreferenceBool(_keyAgreeTermsConditions, agree);
  }

  /// agree terms and conditions [agreeTermsConditions] getter
  /// to get the value from the shared preferences
  bool get agreeTermsConditions {
    return _preferences.getBool(_keyAgreeTermsConditions) ?? false;
  }

  /// intro done [introDone] setter
  /// to store the value in the shared preferences
  set introDone(bool done) {
    logger.finest("set introDone: $done");
    _setSharedPreferenceBool(_keyIntroDone, done);
  }

  /// intro done [introDone] getter
  /// to get the value from the shared preferences
  bool get introDone {
    return _preferences.getBool(_keyIntroDone) ?? false;
  }

  /// notification allowed [notifAllowed] setter
  /// to store the value in the shared preferences
  set notifAllowed(bool? allowed) {
    logger.finest("set notifAllowed: $allowed");
    _setSharedPreferenceBool(_keyNotifAllowed, allowed);
  }

  /// notification allowed [notifAllowed] getter
  /// to get the value from the shared preferences
  bool? get notifAllowed {
    return _preferences.getBool(_keyNotifAllowed);
  }

  /// fcm token [fcmToken] setter
  /// to store the value in the shared preferences
  set fcmToken(String? token) {
    logger.finest("set fcmToken: $token");
    _setSharedPreferenceString(_keyFcmToken, token);
  }

  /// fcm token [fcmToken] getter
  ///  to get the value from the shared preferences
  String? get fcmToken {
    return _preferences.getString(_keyFcmToken);
  }

  /// language [language] setter
  /// to store the value in the shared preferences
  set language(String? language) {
    logger.finest("set language: $language");
    _setSharedPreferenceString(_keyLanguage, language);
  }

  /// language [language] getter
  /// to get the value from the shared preferences
  String? get language {
    return _preferences.getString(_keyLanguage);
  }

  /// authorized calendars [allCalendars] setter
  /// to store the value in the shared preferences
  set authorizedCalendarsId(List<String>? calendarsId) {
    logger.finest("set authorizedCalendars: $calendarsId");
    _setSharedPreferenceString(
        _keyAuthorizedCalendars, json.encode(calendarsId));
  }

  /// authorized calendars [allCalendars] getter
  /// to get the value from the shared preferences
  List<String>? get authorizedCalendarsId {
    final String? calendars = _preferences.getString(_keyAuthorizedCalendars);
    if (calendars == null) {
      return null;
    }
    return json.decode(calendars).cast<String>();
  }

  /// [vocalMessageAutoPlay] setter
  /// to store the value in the shared preferences
  set vocalMessageAutoPlay(bool autoPlay) {
    logger.finest("set vocalMessageAutoPlay: $autoPlay");
    _setSharedPreferenceBool(_keyVocalMessageAutoPlay, autoPlay);
  }

  /// [vocalMessageAutoPlay] getter
  /// to get the value from the shared preferences
  bool get vocalMessageAutoPlay {
    return _preferences.getBool(_keyVocalMessageAutoPlay) ?? true;
  }

  /// [askedForCalendarAccessOnce] setter
  /// to store the value in the shared preferences
  set askedForCalendarAccessOnce(bool asked) {
    logger.finest("set askedForCalendarAccessOnce: $asked");
    _setSharedPreferenceBool(_keyAskedForCalendarAccessOnce, asked);
  }

  /// [askedForCalendarAccessOnce] getter
  /// to get the value from the shared preferences
  bool get askedForCalendarAccessOnce {
    return _preferences.getBool(_keyAskedForCalendarAccessOnce) ?? false;
  }

  /// [hasAlreadyDoneTask] setter
  /// to store the value in the shared preferences
  set hasAlreadyDoneTask(bool hasDone) {
    logger.finest("set hasAlreadyDoneTask: $hasDone");
    _setSharedPreferenceBool(_keyHasAlreadyDoneTask, hasDone);
  }

  /// [hasAlreadyDoneTask] getter
  /// to get the value from the shared preferences
  bool get hasAlreadyDoneTask {
    return _preferences.getBool(_keyHasAlreadyDoneTask) ?? false;
  }

  /// [onboardingPresented] setter
  /// to store the value in the shared preferences
  set onboardingPresented(bool presented) {
    logger.finest("set onboardingPresented: $presented");
    _setSharedPreferenceBool(_keyOnboardingPresented, presented);
  }

  /// [onboardingPresented] getter
  /// to get the value from the shared preferences
  bool get onboardingPresented {
    return _preferences.getBool(_keyOnboardingPresented) ?? false;
  }

  /// private method to set string the shared preferences
  /// if the value is null, the key will be removed
  /// else the key will be set to the value
  Future<void> _setSharedPreferenceString(String key, String? value) async {
    if (value == null) {
      await _preferences.remove(key);
    } else {
      await _preferences.setString(key, value);
    }
  }

  /// private method to set bool to the the shared preferences
  /// if the value is null, the key will be removed
  /// else the key will be set to the value
  Future<void> _setSharedPreferenceBool(String key, bool? value) async {
    if (value == null) {
      await _preferences.remove(key);
    } else {
      await _preferences.setBool(key, value);
    }
  }

  /// [clearSharedPreferences] function
  /// clear all the shared preferences
  /// use this method when logging the user out
  Future<void> clearSharedPreferences() async {
    await _preferences.clear();
  }
}
