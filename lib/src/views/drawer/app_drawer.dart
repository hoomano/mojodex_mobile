import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mojodex_mobile/src/views/new_user_task_execution/new_user_task_execution.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_list/user_task_execution_list.dart';
import 'package:provider/provider.dart';

import '../../../DS/design_system.dart' as ds;
import '../../../DS/theme/themes.dart';
import '../../models/language/system_language.dart';
import '../../models/user/user.dart';
import '../home_screen/home_screen.dart';
import '../settings_view/settings_view.dart';
import '../todos_view/todos_view.dart';
import '../widgets/profile_picture.dart';
import '../workflows_view/new_user_workflow_execution.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);
    return Drawer(
        backgroundColor: ds.DesignColor.grey.grey_7,
        child: Column(children: [
          const SizedBox(
            height: 80,
          ),
          Text(labelsProvider.getText(key: "appDrawer.title"),
              style: TextStyle(
                  color: ds.DesignColor.grey.grey_1,
                  fontSize: ds.TextFontSize.h4)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(
                  left: ds.Spacing.smallPadding, top: ds.Spacing.mediumPadding),
              children: [
                DrawerPageItem(
                    icon: Icon(
                      Icons.home_outlined,
                      color: ds.DesignColor.grey.grey_1,
                    ),
                    title: "Home",
                    routeToGo: HomeScreen.routeName),
                DrawerPageItem(
                    icon: ds.DesignIcon.suitcase(
                      size: ds.TextFontSize.body1,
                    ),
                    title: "New workflow",
                    replacement: false,
                    routeToGo: NewUserWorkflowExecution.routeName),
                DrawerPageItem(
                    icon: ds.DesignIcon.addPlus(
                      size: ds.TextFontSize.body1,
                    ),
                    title:
                        labelsProvider.getText(key: "appDrawer.newTaskButton"),
                    replacement: false,
                    routeToGo: NewUserTaskExecution.routeName),
                DrawerPageItem(
                    icon: ds.DesignIcon.moreGridBig(
                      size: ds.TextFontSize.body1,
                    ),
                    title:
                        labelsProvider.getText(key: "appDrawer.taskListButton"),
                    beforeNavigate: () {
                      User().userTaskExecutionsHistory.refreshLocalList();
                    },
                    routeToGo: !User().userTaskExecutionsHistory.loading &&
                            User().userTaskExecutionsHistory.isEmpty &&
                            User()
                                    .userTaskExecutionsHistory
                                    .userTaskExecutionsAreFilteredBy ==
                                null
                        ? NewUserTaskExecution.routeName
                        : UserTaskExecutionsListView.routeName),
                ValueListenableBuilder(
                    valueListenable: User().todoList.nNotReadTodosNotifier,
                    builder: (context, notReadTodos, child) {
                      return ds.Pills.primary(
                        type: ds.PillsType.fill,
                        alignment: AlignmentDirectional.centerStart,
                        visibility: notReadTodos > 0,
                        child: DrawerPageItem(
                            icon: ds.DesignIcon.circleCheck(
                              size: ds.TextFontSize.body1,
                            ),
                            title: labelsProvider.getText(
                                key: "appDrawer.todosButton"),
                            routeToGo: TodosListView.routeName),
                      );
                    })
              ],
            ),
          ),
          Container(
              height: 80,
              color: ds.DesignColor.grey.grey_5,
              child: Container(
                padding: const EdgeInsets.all(ds.Spacing.smallPadding),
                margin: const EdgeInsets.all(ds.Spacing.smallPadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                          onTap: () {
                            context
                                .pushReplacementNamed(SettingsView.routeName);
                          },
                          child: Row(
                            children: [
                              SizedBox(
                                  width: 40,
                                  child: ProfilePicture(
                                      data: User().profilePicture)),
                              ds.Space.horizontalSmall,
                              Padding(
                                padding: const EdgeInsets.all(
                                    ds.Spacing.smallPadding),
                                child: Text(
                                  User().name ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                      color: ds.DesignColor.grey.grey_1,
                                      fontSize: ds.TextFontSize.body2),
                                ),
                              ),
                            ],
                          )),
                    ),
                    Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {
                            context.pop();
                            User().logout();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ds.DesignIcon.interface(
                                size: 30, color: ds.DesignColor.grey.grey_1),
                          )),
                    ),
                  ],
                ),
              ))
        ]));
  }
}

class DrawerPageItem extends StatelessWidget {
  final Widget icon;
  final String title;
  final String routeToGo;
  final Function? beforeNavigate;
  final bool replacement;
  const DrawerPageItem(
      {required this.icon,
      required this.title,
      required this.routeToGo,
      this.beforeNavigate,
      this.replacement = true,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          icon,
          ds.Space.horizontalSmall,
          Expanded(
            child: Text(title,
                style: TextStyle(
                    color: ds.DesignColor.grey.grey_1,
                    fontSize: ds.TextFontSize.body1)),
          ),
        ],
      ),
      onTap: () async {
        String currentRouteName =
            GoRouter.of(context).routeInformationProvider.value.uri.toString();
        if (currentRouteName == routeToGo) {
          context.pop();
          return;
        }
        beforeNavigate?.call();
        if (replacement) {
          context.pushReplacementNamed(routeToGo);
        } else {
          context.pushNamed(routeToGo);
        }
      },
    );
  }
}
