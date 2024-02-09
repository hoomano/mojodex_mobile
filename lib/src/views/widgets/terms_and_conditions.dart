import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../DS/design_system.dart' as ds;
import '../../../DS/theme/themes.dart';
import '../../models/language/system_language.dart';
import '../../models/user/user.dart';

class TermsAndConditionsTile {
  bool _check = false;
  void onCheck() {
    _check = !_check;
  }

  TermsAndConditionsCheck get termsAndConditionsCheck =>
      TermsAndConditionsCheck(onCheck: onCheck);

  ds.Modal constructModal(BuildContext context, labelsProvider) {
    return ds.Modal(
      icon: labelsProvider.getText(key: "onboarding.termsAndConditions.emoji"),
      title: labelsProvider.getText(key: "onboarding.termsAndConditions.title"),
      textContent: dotenv.env.containsKey('TERMS_OF_SERVICE_URL')
          ? labelsProvider.getText(
              key: "onboarding.termsAndConditions.termsModalContent")
          : labelsProvider.getText(
              key: "onboarding.termsAndConditions.defaultModalContent"),
      widgetContent: termsAndConditionsCheck,
      acceptButtonText: labelsProvider.getText(
          key: "onboarding.termsAndConditions.acceptButtonText"),
      onAccept: () async {
        if (_check) {
          bool success = await User().setTermsAndConditions();
          if (success) {
            context.pop();
          }
        }
      },
      barrierDismissible: false,
    );
  }

  void show(BuildContext context, labelsProvider) {
    constructModal(context, labelsProvider).show(context);
  }
}

class TermsAndConditionsCheck extends StatefulWidget {
  final Function onCheck;

  TermsAndConditionsCheck({required this.onCheck});

  @override
  State<TermsAndConditionsCheck> createState() =>
      _TermsAndConditionsCheckState();
}

class _TermsAndConditionsCheckState extends State<TermsAndConditionsCheck> {
  bool _check = false;

  Future<void> _launchURL(BuildContext context) async {
    try {
      await launchUrl(
        Uri.parse(dotenv.env['TERMS_OF_SERVICE_URL']!),
      );
    } catch (e) {
      // An exception is thrown if browser app is not installed on Android device.
      debugPrint(e.toString());
    }
  }

  void onCheck(bool? value) {
    if (value == null) return;
    widget.onCheck();
    setState(() {
      _check = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);
    return dotenv.env.containsKey('TERMS_OF_SERVICE_URL')
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                  onPressed: () => _launchURL(context),
                  child: RichText(
                      textAlign: TextAlign.right,
                      text: TextSpan(
                          text: labelsProvider.getText(
                              key: "onboarding.termsAndConditions.IAgree"),
                          style: TextStyle(
                              color: themeProvider.themeMode == ThemeMode.dark
                                  ? ds.DesignColor.grey.grey_1
                                  : ds.DesignColor.grey.grey_9,
                              fontWeight: FontWeight.bold),
                          children: <TextSpan>[
                            TextSpan(
                                text: labelsProvider.getText(
                                    key:
                                        "onboarding.termsAndConditions.termsAndConditions"),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ds.DesignColor.primary.dark)),
                          ]))),
              Checkbox(
                value: _check,
                onChanged: onCheck,
                activeColor: ds.DesignColor.primary.main,
              )
            ],
          )
        : Column(
            children: [
              ds.Space.verticalLarge,
              Row(
                children: [
                  Checkbox(
                    value: _check,
                    onChanged: onCheck,
                    activeColor: ds.DesignColor.primary.main,
                  ),
                  Flexible(
                    child: Text(
                        labelsProvider.getText(
                            key:
                                "onboarding.termsAndConditions.defaultAgreement"),
                        style: TextStyle(
                          color: themeProvider.themeMode == ThemeMode.dark
                              ? ds.DesignColor.grey.grey_1
                              : ds.DesignColor.grey.grey_9,
                        ),
                        textAlign: TextAlign.center),
                  )
                ],
              )
            ],
          );
  }
}
