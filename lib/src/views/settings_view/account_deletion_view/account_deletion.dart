import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/language/system_language.dart';
import 'package:mojodex_mobile/src/views/widgets/common_scaffold.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../../DS/theme/themes.dart';
import '../../../models/user/user.dart';

class AccountDeletionView extends StatelessWidget {
  static String routeName = "account_deletion";
  final Logger logger = Logger('AccountDeletion');

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);
    return MojodexScaffold(
      appBarTitle: labelsProvider.getText(key: "accountDeletion.appBarTitle"),
      safeAreaOverflow: false,
      body: Padding(
        padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
        child: Column(
          children: [
            Text(
              labelsProvider.getText(key: "accountDeletion.title"),
              style: TextStyle(
                fontSize: ds.TextFontSize.h3,
                color: themeProvider.themeMode == ThemeMode.dark
                    ? ds.DesignColor.grey.grey_1
                    : ds.DesignColor.grey.grey_9,
              ),
            ),
            ds.Space.verticalLarge,
            Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color: themeProvider.themeMode == ThemeMode.dark
                    ? ds.DesignColor.grey.grey_7
                    : ds.DesignColor.grey.grey_1,
                child: Padding(
                  padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
                  child:
                      Text(labelsProvider.getText(key: "accountDeletion.body"),
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: ds.TextFontSize.body2,
                            color: themeProvider.themeMode == ThemeMode.dark
                                ? ds.DesignColor.grey.grey_3
                                : ds.DesignColor.grey.grey_9,
                          )),
                ),
              ),
            ),
            ds.Space.verticalLarge,
            Padding(
              padding: const EdgeInsets.symmetric(vertical: ds.Spacing.base),
              child: ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                tileColor: ds.DesignColor.status.error,
                textColor: ds.DesignColor.grey.grey_1,
                title: Center(
                  child: Text(
                      labelsProvider.getText(
                          key: "accountDeletion.requestAccountDeletionButton"),
                      style: const TextStyle(fontSize: ds.TextFontSize.body1)),
                ),
                onTap: () => User().deleteAccount(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
