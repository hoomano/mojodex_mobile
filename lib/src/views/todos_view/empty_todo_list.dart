import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/models/language/system_language.dart';
import 'package:provider/provider.dart';

import '../../../DS/design_system.dart' as ds;
import '../../../DS/theme/themes.dart';
import '../../models/user/user.dart';

class EmptyTodoList extends StatelessWidget {
  EmptyTodoList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);
    return Padding(
      padding: const EdgeInsets.all(ds.Spacing.largePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "🎉",
            style: TextStyle(
                fontSize: ds.TextFontSize.h4,
                color: themeProvider.themeMode == ThemeMode.dark
                    ? ds.DesignColor.grey.grey_1
                    : ds.DesignColor.grey.grey_9),
          ),
          Text(
            User().todoList.neverDoneTodos
                ? labelsProvider.getText(
                    key: "todos.neverDoneTodosTitleMessage")
                : labelsProvider.getText(
                    key: "todos.notNeverDoneTodosTitleMessage"),
            style: TextStyle(
                fontSize: ds.TextFontSize.h4,
                color: themeProvider.themeMode == ThemeMode.dark
                    ? ds.DesignColor.grey.grey_1
                    : ds.DesignColor.grey.grey_9),
          ),
          ds.Space.verticalSmall,
          if (User().todoList.neverDoneTodos)
            Text(
              labelsProvider.getText(key: "todos.neverDoneTodosBodyMessage"),
              style: TextStyle(
                  fontSize: ds.TextFontSize.body1,
                  color: themeProvider.themeMode == ThemeMode.dark
                      ? ds.DesignColor.grey.grey_3
                      : ds.DesignColor.grey.grey_5),
            ),
        ],
      ),
    );
  }
}
