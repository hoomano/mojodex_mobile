import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../DS/design_system.dart' as ds;
import '../../../DS/theme/themes.dart';
import '../widgets/common_scaffold.dart';

class DeletedUserTaskExecution extends StatelessWidget {
  const DeletedUserTaskExecution({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MojodexScaffold(
        appBarTitle: "Nothing here",
        safeAreaOverflow: false,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "🤷‍♂️",
                  style: TextStyle(
                      fontSize: ds.TextFontSize.h4,
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? ds.DesignColor.grey.grey_1
                          : ds.DesignColor.grey.grey_9),
                ),
                Text(
                  "Uh-oh! Couldn't find that task. It may have been deleted or the link is off.",
                  style: TextStyle(
                      fontSize: ds.TextFontSize.h4,
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? ds.DesignColor.grey.grey_1
                          : ds.DesignColor.grey.grey_9),
                ),
              ],
            ),
          ),
        ));
  }
}
