import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/views/settings_view/account_deletion_view/account_deletion.dart';
import 'package:mojodex_mobile/src/views/settings_view/auto_play_vocal_switcher.dart';
import 'package:mojodex_mobile/src/views/settings_view/plan_view/plan_view.dart';
import 'package:mojodex_mobile/src/views/widgets/common_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../DS/design_system.dart' as ds;
import '../../../DS/theme/themes.dart';
import '../../models/language/system_language.dart';
import '../../models/user/user.dart';
import '../drawer/app_drawer.dart';
import '../widgets/profile_picture.dart';

class SettingsView extends StatefulWidget {
  static String routeName = "settings";

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final Logger logger = Logger('SettingsView');

  bool _changingLanguage = false;

  void _showLanguageBottomSheet(BuildContext context, labelsProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding:
              const EdgeInsets.symmetric(vertical: ds.Spacing.smallSpacing),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: labelsProvider.availableLanguages.keys
                  .map((languageCode) {
                    return ListTile(
                      title: Center(
                          child: Text(
                              labelsProvider.availableLanguages[languageCode])),
                      onTap: () async {
                        Navigator.pop(context);
                        setState(() => _changingLanguage = true);
                        try {
                          await labelsProvider.updateLanguage(
                              languageCode: languageCode);
                          setState(() {
                            _changingLanguage = false;
                          });
                        } catch (e) {
                          setState(() => _changingLanguage = false);
                          rethrow;
                        }
                      },
                    );
                  })
                  .toList()
                  .cast<Widget>()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);
    String languageSelected =
        labelsProvider.availableLanguages[User().language];
    return MojodexScaffold(
      safeAreaOverflow: false,
      drawer: AppDrawer(),
      appBarTitle: labelsProvider.getText(key: "account.appBarTitle"),
      body: Padding(
          padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: themeProvider.themeMode == ThemeMode.dark
                    ? ds.DesignColor.grey.grey_9
                    : ds.DesignColor.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: ds.Spacing.mediumPadding),
                  child: Column(
                    children: [
                      ProfilePicture(data: User().profilePicture),
                      ds.Space.verticalSmall,
                      Text(
                        User().name ?? "",
                        style: TextStyle(
                          fontSize: ds.TextFontSize.h4,
                          color: themeProvider.themeMode == ThemeMode.dark
                              ? ds.DesignColor.grey.grey_1
                              : ds.DesignColor.grey.grey_9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    AccountSection(
                      title: labelsProvider.getText(
                          key: "account.accountSectionTitle"),
                      items: [
                        Item(
                            text: labelsProvider.getText(
                                key: "account.planButton"),
                            onTap: (context) async {
                              await User().purchaseManager.refreshPurchase();
                              context.go(
                                  '/${SettingsView.routeName}/${PlanView.routeName}');
                            }),
                        Item(
                            text: labelsProvider.getText(
                                key: "account.deleteAccountButton"),
                            onTap: (context) => context.go(
                                '/${SettingsView.routeName}/${AccountDeletionView.routeName}')),
                      ],
                    ),
                    AccountSection(
                      title: labelsProvider.getText(
                          key: "account.securitySectionTitle"),
                      items: [
                        if (dotenv.env.containsKey('TERMS_OF_SERVICE_URL'))
                          Item(
                              text: labelsProvider.getText(
                                  key: "account.termsOfUseButton"),
                              onTap: (context) async {
                                await launchUrl(
                                  Uri.parse(
                                      dotenv.env['TERMS_OF_SERVICE_URL']!),
                                );
                              }),
                        if (dotenv.env.containsKey('PRIVACY_POLICY_URL'))
                          Item(
                              text: labelsProvider.getText(
                                  key: "account.privacyPolicyButton"),
                              onTap: (context) async {
                                await launchUrl(
                                  Uri.parse(dotenv.env['PRIVACY_POLICY_URL']!),
                                );
                              })
                      ],
                    ),
                    ds.Space.verticalMedium,
                    ListTile(
                        title: Text(
                            labelsProvider.getText(
                                key: "account.darkModeButton"),
                            style: TextStyle(
                                color: themeProvider.themeMode == ThemeMode.dark
                                    ? ds.DesignColor.grey.grey_1
                                    : ds.DesignColor.grey.grey_9,
                                fontSize: ds.TextFontSize.body1)),
                        trailing: Switch.adaptive(
                          value: themeProvider.themeMode == ThemeMode.dark,
                          onChanged: (value) {
                            if (themeProvider.themeMode == ThemeMode.dark) {
                              themeProvider.setTheme(ThemeMode.light);
                            } else {
                              themeProvider.setTheme(ThemeMode.dark);
                            }
                          },
                          activeColor: ds.DesignColor.primary.dark,
                          inactiveThumbColor: ds.DesignColor.grey.grey_3,
                        )),
                    ds.Space.verticalMedium,
                    AutoPlayVocalSwitcher(),
                    ds.Space.verticalMedium,
                    AccountItemWidget(
                        text: labelsProvider.getText(
                            key: "account.languageButton"),
                        trailing: Text(languageSelected,
                            style: TextStyle(
                                color: themeProvider.themeMode == ThemeMode.dark
                                    ? ds.DesignColor.grey.grey_1
                                    : ds.DesignColor.grey.grey_9,
                                fontSize: ds.TextFontSize.body2)),
                        onTap: (context) =>
                            _showLanguageBottomSheet(context, labelsProvider)),
                    ds.Space.verticalMedium,
                    Center(
                      child: Text("Mojodex - v${dotenv.env['VERSION']!}",
                          style: TextStyle(color: ds.DesignColor.grey.grey_3)),
                    )
                  ],
                ),
              ),
            ],
          )),
      bottomBarWidget: SizedBox(
          height: 20,
          child: _changingLanguage
              ? LinearProgressIndicator(
                  color: ds.DesignColor.primary.main,
                  backgroundColor: themeProvider.themeMode == ThemeMode.dark
                      ? ds.DesignColor.grey.grey_7
                      : ds.DesignColor.grey.grey_3,
                )
              : Container()),
    );
  }
}

class AccountItemWidget extends StatelessWidget {
  final String text;
  final Widget? trailing;
  final dynamic Function(BuildContext context) onTap;
  const AccountItemWidget(
      {required this.text, this.trailing, required this.onTap, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ds.Spacing.base),
      child: ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          tileColor: themeProvider.themeMode == ThemeMode.dark
              ? ds.DesignColor.grey.grey_7
              : ds.DesignColor.grey.grey_1,
          title: Text(text,
              style: TextStyle(
                  fontSize: ds.TextFontSize.body1,
                  color: themeProvider.themeMode == ThemeMode.dark
                      ? ds.DesignColor.grey.grey_3
                      : ds.DesignColor.grey.grey_9)),
          trailing: trailing ??
              ds.DesignIcon.chevronRight(
                  color: ds.DesignColor.grey.grey_3,
                  size: ds.TextFontSize.body1),
          onTap: () => onTap(context)),
    );
  }
}

class AccountSectionTitleWidget extends StatelessWidget {
  final String text;
  const AccountSectionTitleWidget({required this.text, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: ds.Spacing.smallPadding,
          vertical: ds.Spacing.mediumPadding),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: ds.TextFontSize.h4,
          color: themeProvider.themeMode == ThemeMode.dark
              ? ds.DesignColor.grey.grey_1
              : ds.DesignColor.grey.grey_9,
        ),
      ),
    );
  }
}

class AccountSection extends StatelessWidget {
  final String title;
  final List<Item> items;
  const AccountSection({required this.title, required this.items, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AccountSectionTitleWidget(text: title),
      ...items
          .map((item) => AccountItemWidget(
                text: item.text,
                onTap: item.onTap,
              ))
          .toList()
    ]);
  }
}

class Item {
  final String text;
  final dynamic Function(BuildContext context) onTap;
  const Item({required this.text, required this.onTap});
}
