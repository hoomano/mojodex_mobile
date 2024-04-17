import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mojodex_mobile/src/app_router.dart';
import 'package:mojodex_mobile/src/microphone.dart';
import 'package:mojodex_mobile/src/models/language/system_language.dart';
import 'package:mojodex_mobile/src/models/tasks/user_task_executions_history.dart';
import 'package:mojodex_mobile/src/models/tasks/user_tasks_list.dart';
import 'package:mojodex_mobile/src/models/todos/todo-list.dart';
import 'package:mojodex_mobile/src/models/user/user.dart';
import 'package:mojodex_mobile/src/notifications_manager.dart';
import 'package:mojodex_mobile/src/role_manager/role_manager.dart';
import 'package:provider/provider.dart';

import '../../../DS/design_system.dart' as ds;
import 'DS/theme/themes.dart';

class MojodexApp extends StatefulWidget {
  @override
  State<MojodexApp> createState() => _MojodexAppState();
}

class _MojodexAppState extends State<MojodexApp> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (User().isLoggedIn) {
      if (state == AppLifecycleState.resumed) {
        // let's refresh the list each time the app is resumed
        User().userTaskExecutionsHistory.refreshLocalList();
        User().userTasksList.refreshLocalList();
        User().todoList.refreshLocalList();
        if (User().language != null) {
          SystemLanguage().refreshFromBackend(languageCode: User().language!);
        }
      } else if (state == AppLifecycleState.inactive) {
        User().userTaskExecutionsHistory.saveItemsToFile();
        User().userTasksList.saveItemsToFile();
        User().todoList.saveItemsToFile();
      }
    }
  }

  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<User>(create: (context) => User()),
          ChangeNotifierProvider<UserTasksList>.value(
              value: User().userTasksList),
          ChangeNotifierProvider<UserTaskExecutionsHistory>.value(
              value: User().userTaskExecutionsHistory),
          ChangeNotifierProvider<TodoList>.value(value: User().todoList),
          ChangeNotifierProvider<Microphone>(create: (context) => Microphone()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => SystemLanguage()),
          ChangeNotifierProvider<RoleManager>.value(value: User().roleManager),
        ],
        child: Consumer<User>(builder: (context, user, child) {
          AppRouter().updateRouter(user: user);

          if (user.isLoggedIn &&
              !NotificationsManager().initialized &&
              dotenv.env.containsKey("FIREBASE_APP_NAME")) {
            NotificationsManager().initializeAsync();
          }

          return MaterialApp.router(
            theme: ThemeData(
              fontFamily: 'HankenGrotesk',
              primaryColor: ds.DesignColor.primary.main,
            ),
            routerConfig: AppRouter().goRouter,
            debugShowCheckedModeBanner: false,
          );
        }));
  }
}
