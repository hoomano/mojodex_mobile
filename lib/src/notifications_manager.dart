import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/app_router.dart';
import 'package:mojodex_mobile/src/models/tasks/user_task_execution.dart';
import 'package:mojodex_mobile/src/views/new_user_task_execution/new_user_task_execution.dart';
import 'package:mojodex_mobile/src/views/settings_view/plan_view/plan_view.dart';
import 'package:mojodex_mobile/src/views/settings_view/settings_view.dart';
import 'package:mojodex_mobile/src/views/todos_view/todos_view.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_list/user_task_execution_list.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_view/user_task_execution_view.dart';

import 'models/tasks/user_task.dart';
import 'models/user/user.dart';

/// This class is used to manage notifications
/// It is a singleton
/// It uses FirebaseCloudMessaging and FlutterLocalNotifications packages
class NotificationsManager {
  // Logger
  final Logger logger = Logger('NotificationsManager');

  bool _initialized = false;
  bool get initialized => _initialized;

  bool _initializing = false;
  bool get initializing => _initializing;

  /// FirebaseCloudMessaging token, identifying the device
  late String token;

  /// initializationSettings for FlutterLocalNotifications
  late InitializationSettings initializationSettings;

  /// AndroidNotificationChannel to display notifications on Android even when the app is in the foreground
  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  /// FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// AndroidInitializationSettings
  final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('launch_icon');

  /// the private constructor of the class
  /// it will be call once when the class is created
  NotificationsManager._privateConstructor();

  /// Unique instance of the class [_instance]
  static final NotificationsManager _instance =
      NotificationsManager._privateConstructor();

  /// factory constructor of the class
  factory NotificationsManager() {
    return _instance;
  }

  /// Sets up the functionality to handle interactions with messages when user taps on a notification
  Future<void> _setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage.data);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp
        .listen((RemoteMessage message) => _handleMessage(message.data));
  }

  /// This method handles the incoming message data and processes it accordingly.
  Future<void> _handleMessage(Map<String, dynamic> data) async {
    if (data.containsKey('user_task_execution_pk')) {
      UserTaskExecution? userTaskExecution = await User()
          .userTaskExecutionsHistory
          .getParticularItem(int.parse(data['user_task_execution_pk']));
      if (userTaskExecution != null) {
        String? initialTab;
        if (data.containsKey('type')) {
          if (data['type'] == 'todos') {
            initialTab = UserTaskExecutionView.todosTabName;
          } else if (data['type'] == 'chat') {
            initialTab = UserTaskExecutionView.chatTabName;
          } else if (data['type'] == 'result') {
            initialTab = UserTaskExecutionView.resultTabName;
          }
        }
        AppRouter().goRouter.push(
            '/${UserTaskExecutionsListView.routeName}/${userTaskExecution.pk}',
            extra: UserTaskExecutionView(
              userTaskExecution: userTaskExecution,
              initialTab: initialTab ?? UserTaskExecutionView.resultTabName,
            ));
      }
    } else if (data.containsKey('type')) {
      if (data['type'] == 'new_user_task_execution') {
        AppRouter().goRouter.pushNamed(NewUserTaskExecution.routeName);
      } else if (data['type'] == 'todos') {
        AppRouter().goRouter.pushNamed(TodosListView.routeName);
      } else if (data['type'] == 'calendar_suggestion') {
        if (data.containsKey('task_pk')) {
          int taskPk = int.parse(data['task_pk']);
          UserTask? userTask =
              User().userTasksList.getUserTaskFromTaskPk(taskPk);
          if (userTask == null) {
            return;
          }
          UserTaskExecution? newUserTaskExecution = await userTask.newExecution(
            onPaymentError: () async {
              await User().roleManager.refreshRole();
              AppRouter()
                  .goRouter
                  .push('/${SettingsView.routeName}/${PlanView.routeName}');
            },
          );
          if (newUserTaskExecution == null) {
            return;
          }
          UserTaskExecutionView userTaskExecutionView = UserTaskExecutionView(
              userTaskExecution: newUserTaskExecution,
              initialTab: UserTaskExecutionView.chatTabName,
              refreshUserTaskExecution: false);
          AppRouter().goRouter.push(
              '/${UserTaskExecutionsListView.routeName}/${newUserTaskExecution.pk}',
              extra: userTaskExecutionView);
        }
      }
    }
  }

  /// Gets the token from FirebaseCloudMessaging
  Future<String?> getFcmToken() async {
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } on FirebaseException catch (e) {
      logger.shout("🔴 getToken error: ${e.code}");
      if (e.code == 'apns-token-not-set') {
        // APNS token is not yet available => sleep 1s and try again
        await Future.delayed(const Duration(seconds: 1));
        fcmToken = await getFcmToken();
      }
    }
    return fcmToken;
  }

  /// Ask the user for permission to send notifications
  Future<void> askPermission() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    logger.info('User granted permission: ${settings.authorizationStatus}');
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      User().notifAllowed = true;
      setUpNotifications();
    } else {
      User().notifAllowed = false;
    }
  }

  /// Sets up the notifications reception
  Future<void> setUpNotifications() async {
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        // FOREGROUND ANDROID
        onDidReceiveNotificationResponse: (NotificationResponse notification) {
      Map<String, dynamic> payload = jsonDecode(notification.payload!);
      _handleMessage(payload);
    });

    // foreground: When the application is open, in view and in use.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                icon: 'launch_icon',
                // other properties...
              ),
            ),
            payload: jsonEncode(message.data));
      }
    });

    // Run code required to handle interacted messages in an async function
    // as initState() must not be async
    // FOREGROUND & BACKGROUND IOS
    _setupInteractedMessage();
  }

  /// Initializes the notifications manager
  Future<void> initializeAsync() async {
    if (_initializing || _initialized) {
      return;
    }
    _initializing = true;

    // get fcm token
    token = (await getFcmToken())!;

    if (User().fcmToken == null || User().fcmToken != token) {
      Map<String, dynamic>? success = await User().putDevice(fcmToken: token);
      if (success != null) {
        User().fcmToken = token;
      }
    }
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      token = fcmToken;

      if (User().fcmToken == null || User().fcmToken != token) {
        Map<String, dynamic>? success = await User().putDevice(fcmToken: token);
        if (success != null) {
          User().fcmToken = token;
        }
      }
    }).onError((err) {
      logger.shout('onTokenRefresh error: $err');
    });
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
    initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: DarwinInitializationSettings());

    if (User().notifAllowed != null && User().notifAllowed!) {
      setUpNotifications();
    }
    _initializing = false;
    _initialized = true;
  }
}
