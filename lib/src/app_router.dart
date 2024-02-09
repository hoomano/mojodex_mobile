import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/views/login_view/signin.dart';
import 'package:mojodex_mobile/src/views/login_view/signup.dart';
import 'package:mojodex_mobile/src/views/new_user_task_execution/new_user_task_execution.dart';
import 'package:mojodex_mobile/src/views/onboarding/onboarding_page_controller.dart';
import 'package:mojodex_mobile/src/views/reset_password/reset_password_view.dart';
import 'package:mojodex_mobile/src/views/settings_view/account_deletion_view/account_deletion.dart';
import 'package:mojodex_mobile/src/views/settings_view/calendar_settings_view/calendarSettingsView.dart';
import 'package:mojodex_mobile/src/views/settings_view/plan_view/plan_view.dart';
import 'package:mojodex_mobile/src/views/settings_view/settings_view.dart';
import 'package:mojodex_mobile/src/views/todos_view/todos_view.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_list/user_task_execution_list.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_view/load_user_task_execution_view.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_view/user_task_execution_view.dart';

import 'models/user/user.dart';

class AppRouter {
  // Logger
  final Logger logger = Logger('AppRouter');

  // Unique instance of the class
  static final AppRouter _instance = AppRouter.privateConstructor();

  // Private constructor of the class, called once when the class is created
  AppRouter.privateConstructor();

  factory AppRouter() => _instance;

  String initialLocation = '/${UserTaskExecutionsListView.routeName}';

  late GoRouter _goRouter;
  GoRouter get goRouter => _goRouter;

  void updateRouter({required User user}) {
    _goRouter = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/${UserTaskExecutionsListView.routeName}',
          name: UserTaskExecutionsListView.routeName,
          builder: (context, state) => UserTaskExecutionsListView(),
          routes: [
            GoRoute(
              path: ':userTaskExecutionPk',
              builder: (context, state) {
                if (state.extra != null) {
                  return state.extra as UserTaskExecutionView;
                }
                return LoadUserTaskExecutionView(
                  userTaskExecutionPk:
                      int.parse(state.pathParameters['userTaskExecutionPk']!),
                  initialTab: state.uri.queryParameters['initialTab'] ??
                      UserTaskExecutionView.resultTabName,
                );
              },
            ),
          ],
        ),
        GoRoute(
            path: "/${NewUserTaskExecution.routeName}",
            name: NewUserTaskExecution.routeName,
            builder: (context, state) {
              return NewUserTaskExecution();
            }),
        GoRoute(
            path: "/${TodosListView.routeName}",
            name: TodosListView.routeName,
            builder: (context, state) {
              return TodosListView();
            }),
        GoRoute(
            path: "/${SettingsView.routeName}",
            name: SettingsView.routeName,
            builder: (context, state) {
              return SettingsView();
            },
            routes: [
              GoRoute(
                path: ':setting',
                builder: (context, state) {
                  String? setting = state.pathParameters['setting'];
                  if (setting == PlanView.routeName) {
                    return PlanView();
                  }
                  if (setting == CalendarSettingsView.routeName) {
                    return CalendarSettingsView();
                  }
                  if (setting == AccountDeletionView.routeName) {
                    return AccountDeletionView();
                  }
                  return SettingsView();
                },
              )
            ]),
        GoRoute(
            path: "/${SignInView.routeName}",
            name: SignInView.routeName,
            builder: (context, state) {
              return SignInView();
            }),
        GoRoute(
            path: "/${SignUpView.routeName}",
            name: SignUpView.routeName,
            builder: (context, state) {
              return SignUpView();
            }),
        GoRoute(
          path: "/${OnboardingPagesController.routeName}",
          name: OnboardingPagesController.routeName,
          builder: (context, state) {
            return const OnboardingPagesController();
          },
        ),
        GoRoute(
          path: "/auth/${ResetPasswordView.routeName}",
          name: ResetPasswordView.routeName,
          builder: (context, state) {
            return ResetPasswordView(
                token: state.uri.queryParameters['token']!);
          },
        ),
      ],
      redirect: (context, state) {
        if (state.uri.path == "/auth/${ResetPasswordView.routeName}") {
          return null;
        }
        if (!user.isLoggedIn) {
          if (state.uri.path == "/${SignUpView.routeName}") {
            return null;
          }
          return '/${SignInView.routeName}';
        }
        if (!user.onboardingPresented) {
          return '/${OnboardingPagesController.routeName}';
        }
        return null;
      },
      onException: (context, state, exception) {
        _goRouter.go(initialLocation);
      },
    );
  }
}
