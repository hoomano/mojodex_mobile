import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/DS/design_system.dart' as ds;
import 'package:mojodex_mobile/DS/theme/themes.dart';
import 'package:mojodex_mobile/src/models/language/system_language.dart';
import 'package:mojodex_mobile/src/models/user/company.dart';
import 'package:mojodex_mobile/src/models/user/user.dart';
import 'package:mojodex_mobile/src/views/widgets/common_scaffold.dart';
import 'package:mojodex_mobile/src/views/widgets/skip_button_container.dart';
import 'package:provider/provider.dart';

class WebUrlInputView extends StatefulWidget {
  final Function() nextPage;
  final Function() previousPage;
  final Function({int? exactPage, int? nPagesAhead, int? nPagesBack}) goToPage;

  const WebUrlInputView({
    super.key,
    required this.nextPage,
    required this.previousPage,
    required this.goToPage,
  });

  @override
  State<WebUrlInputView> createState() => _WebUrlInputViewState();
}

class _WebUrlInputViewState extends State<WebUrlInputView> {
  final Logger logger = Logger('WelcomeView');

  final _formKey = GlobalKey<FormState>();

  var websiteUrlTextEditingController = TextEditingController();

  Future<void> searchWebUri(String webUri) async {
    if (_formKey.currentState!.validate()) {
      try {
        // Hide keyboard
        FocusScope.of(context).unfocus();

        // It neccessary to wait a bit to hide the keyboard and show the progress indicator.
        // Otherwise it occurs and overflow error because the keyboard is still visible in the progress indicator view.
        await Future.delayed(const Duration(milliseconds: 100));

        // Show in progess page
        widget.nextPage();

        // ==> call backend and search the site
        User().company = Company();
        bool success = await User().company!.searchFromWebUri(webUri);

        if (success) {
          widget.nextPage();
          return;
        } else {
          // It neccessary to give some delay to avoid an abrupt transition in the cases
          // where the call to backend fail and this line is executed inmediately after the previous one.
          await Future.delayed(const Duration(milliseconds: 200));
          widget.previousPage();
        }
      } catch (e) {
        // This delay is because the same reason as before
        await Future.delayed(const Duration(milliseconds: 200));
        widget.previousPage();
      }
    }
  }

  void onSkipButtonClick() {
    // Skip Loading and company description
    widget.goToPage(nPagesAhead: 3);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);
    return MojodexScaffold(
      automaticallyImplyLeading: false,
      appBarTitle: "",
      safeAreaOverflow: false,
      body: SkipButtonContainer(
        onSkipPressed: onSkipButtonClick,
        child: Form(
          key: _formKey,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: ds.Spacing.smallSpacing),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  labelsProvider.getText(
                      key: "onboarding.webUrlInputPage.emoji"),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: ds.TextFontSize.h1),
                ),
                Text(
                  labelsProvider.getText(
                      key: "onboarding.webUrlInputPage.title"),
                  style: TextStyle(
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? ds.DesignColor.grey.grey_1
                          : ds.DesignColor.grey.grey_9,
                      fontSize: ds.TextFontSize.h2),
                  textAlign: TextAlign.center,
                ),
                Text(
                  labelsProvider.getText(
                      key: "onboarding.webUrlInputPage.body"),
                  style: TextStyle(
                      color: ds.DesignColor.grey.grey_3,
                      fontSize: ds.TextFontSize.body2),
                  textAlign: TextAlign.center,
                ),
                TextFormField(
                  maxLines: 1,
                  minLines: 1,
                  controller: websiteUrlTextEditingController,
                  validator: (value) {
                    var regExp = RegExp(r"^.+\..+$");
                    bool isValid = regExp.hasMatch(value ?? '');
                    if (!isValid) {
                      return labelsProvider.getText(
                          key:
                              "onboarding.webUrlInputPage.validatorErrorMessage");
                    }
                    return null;
                  },
                  style: TextStyle(
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? ds.DesignColor.grey.grey_1
                          : ds.DesignColor.grey.grey_9),
                  decoration: InputDecoration(
                      hintText: labelsProvider.getText(
                          key:
                              "onboarding.webUrlInputPage.webUrlInputHintText"),
                      hintStyle: TextStyle(color: ds.DesignColor.grey.grey_3),
                      filled: true,
                      enabled: true,
                      errorMaxLines: 3,
                      errorStyle: TextStyle(
                          color: ds.DesignColor.status.warning,
                          fontSize: ds.TextFontSize.h6),
                      helperStyle: TextStyle(
                          color: ds.DesignColor.status.warning,
                          fontSize: ds.TextFontSize.h6),
                      fillColor: themeProvider.themeMode == ThemeMode.dark
                          ? ds.DesignColor.grey.grey_7
                          : ds.DesignColor.grey.grey_1,
                      border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          borderSide:
                              BorderSide(color: ds.DesignColor.grey.grey_3))),
                ),
                ds.Button.fill(
                  text: labelsProvider.getText(key: "onboarding.nextButton"),
                  backgroundColor: themeProvider.themeMode == ThemeMode.dark
                      ? ds.DesignColor.primary.dark
                      : ds.DesignColor.primary.main,
                  size: ds.ButtonSize.small,
                  onPressed: () =>
                      searchWebUri(websiteUrlTextEditingController.text),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
