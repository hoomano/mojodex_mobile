import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/firebase_options.dart';
import 'package:mojodex_mobile/mojodex_app.dart';
import 'package:mojodex_mobile/src/models/user/user.dart';
import 'package:mojodex_mobile/src/views/error_view/no_connection_error_view.dart';

List<String> checkEnv() {
  Map<String, String> env = dotenv.env;

  List<String> missingEntries = [];
  if (env['BACKEND_URI'] == null) missingEntries.add('BACKEND_URI');
  if (env['VERSION'] == null) missingEntries.add('VERSION');
  if (env['USE_PLACEHOLDERS'] == null) missingEntries.add('USE_PLACEHOLDERS');
  return missingEntries;
}

void setupLogger(Logger logger) {
  Logger.root.level = Level.FINEST;
  Logger.root.onRecord.listen((record) {
    if (record.loggerName.startsWith('socket_io')) return;

    List<String> prefixs = ["🔴🔴🔴", "🔴", "🟡", "🟣", "🔵", "⚪", "⚪️", "⚪️"];
    List<Level> levels = [
      Level.SHOUT,
      Level.SEVERE,
      Level.WARNING,
      Level.CONFIG,
      Level.INFO,
      Level.FINE,
      Level.FINER,
      Level.FINEST
    ];
    String emojiPrefix = "";
    if (levels.contains(record.level)) {
      emojiPrefix = prefixs[levels.indexOf(record.level)];
    }
    if (kDebugMode) {
      print('$emojiPrefix ${record.loggerName} : ${record.message}');
    }
  });
  logger.config("Logger Level set to: ${Logger.root.level.toString()}");
}

// BACKGROUND ANDROID
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(name: dotenv.env['FIREBASE_APP_NAME']);
}

Future<void> main() async {
  Logger logger = Logger('Main');
  setupLogger(logger);
  logger.config("Starting Main...");
  DateTime mainStart = DateTime.now();
  WidgetsFlutterBinding.ensureInitialized();

  // Set portrait orientation
  List<DeviceOrientation> prefs = [DeviceOrientation.portraitUp];
  await SystemChrome.setPreferredOrientations(prefs);

  // load environment variables
  try {
    await dotenv.load(fileName: "assets/.env");
    List<String> missingEntries = checkEnv();
    if (missingEntries.isNotEmpty) {
      logger.shout(".env incomplete");
      logger.shout("Missing entries: $missingEntries");
      return;
    }
    dotenv.env.forEach((key, value) {
      logger.config("env[${key.padRight(15)}] : $value");
    });
  } catch (e) {
    logger.shout(e);
    return;
  }

  if (dotenv.env.containsKey('FIREBASE_APP_NAME')) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await Firebase.initializeApp(
      name: dotenv.env['FIREBASE_APP_NAME'],
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  DateTime mainEnd = DateTime.now();
  logger.config("Main took ${mainEnd.difference(mainStart)}");
  try {
    logger.config("Starting User login...");
    DateTime startTime = DateTime.now();
    await User().login();
    DateTime endTime = DateTime.now();
    logger.config("User login took ${endTime.difference(startTime)}");
  } on SocketException catch (e) {
    return runApp(const MaterialApp(
        home: NoConnectionErrorView(isInternetConnectionError: true)));
  } on Exception catch (e) {
    return runApp(const MaterialApp(
        home: NoConnectionErrorView(isInternetConnectionError: false)));
  }
  return runApp(MojodexApp());
}
