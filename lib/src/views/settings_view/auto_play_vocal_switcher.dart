import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../DS/design_system.dart' as ds;
import '../../../DS/theme/themes.dart';
import '../../models/language/system_language.dart';
import '../../models/user/user.dart';

class AutoPlayVocalSwitcher extends StatefulWidget {
  const AutoPlayVocalSwitcher({Key? key}) : super(key: key);

  @override
  State<AutoPlayVocalSwitcher> createState() => _AutoPlayVocalSwitcherState();
}

class _AutoPlayVocalSwitcherState extends State<AutoPlayVocalSwitcher> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);
    return ListTile(
        title: Text(labelsProvider.getText(key: "account.autoPlayVocalMessage"),
            style: TextStyle(
                color: themeProvider.themeMode == ThemeMode.dark
                    ? ds.DesignColor.grey.grey_1
                    : ds.DesignColor.grey.grey_9,
                fontSize: ds.TextFontSize.body1)),
        trailing: Switch.adaptive(
          value: User().vocalMessageAutoPlay,
          onChanged: (value) {
            setState(() {
              User().vocalMessageAutoPlay = value;
            });
          },
          activeColor: ds.DesignColor.primary.dark,
          inactiveThumbColor: ds.DesignColor.grey.grey_3,
        ));
  }
}
