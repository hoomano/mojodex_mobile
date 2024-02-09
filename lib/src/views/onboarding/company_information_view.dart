import 'package:flutter/material.dart';
import 'package:mojodex_mobile/DS/design_system.dart' as ds;
import 'package:mojodex_mobile/DS/theme/themes.dart';
import 'package:mojodex_mobile/src/models/language/system_language.dart';
import 'package:mojodex_mobile/src/models/user/user.dart';
import 'package:mojodex_mobile/src/views/widgets/common_scaffold.dart';
import 'package:provider/provider.dart';

class CompanyInformationView extends StatefulWidget {
  final Function? completeOnboarding;

  final Function() nextPage;

  const CompanyInformationView(
      {super.key, this.completeOnboarding, required this.nextPage});

  @override
  State<CompanyInformationView> createState() => _CompanyInformationViewState();
}

class _CompanyInformationViewState extends State<CompanyInformationView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController companyInfoTextEditingController =
      TextEditingController();

  ScrollController scroll = ScrollController();
  var focusNode = FocusNode();

  bool _nextButtonClicked = false;

  bool? _selection;

  Future<bool> setCompanyInformation(String feedback, String correct) async {
    try {
      bool? success = await User().company?.update(feedback, correct);

      if (success!) {
        widget.nextPage();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void onNextButtonClick() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _nextButtonClicked = true);

      bool success = await setCompanyInformation(
          companyInfoTextEditingController.text,
          _selection == true ? "yes" : "no");

      if (!success) {
        setState(() => _nextButtonClicked = false);
      }
    }
  }

  void onSelectOption(bool? val) {
    setState(() => _selection = val);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);

    return MojodexScaffold(
      automaticallyImplyLeading: false,
      appBarTitle: "",
      safeAreaOverflow: false,
      body: RawScrollbar(
        crossAxisMargin: 6,
        controller: scroll,
        thumbVisibility: true,
        trackVisibility: true,
        child: Center(
          child: SingleChildScrollView(
            controller: scroll,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: ds.Spacing.base,
                    horizontal: ds.Spacing.mediumPadding),
                child: Container(
                  decoration: BoxDecoration(
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? ds.DesignColor.grey.grey_7
                          : ds.DesignColor.grey.grey_1,
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: ds.Spacing.base,
                        horizontal: ds.Spacing.largePadding),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.always,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.all(ds.Spacing.smallPadding),
                            child: Text(
                              User().company?.emoji ?? "",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 40,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.all(ds.Spacing.smallPadding),
                            child: Text(
                              User().company?.name ?? "",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color:
                                      themeProvider.themeMode == ThemeMode.dark
                                          ? ds.DesignColor.grey.grey_1
                                          : ds.DesignColor.grey.grey_9,
                                  fontSize: 30),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.all(ds.Spacing.smallPadding),
                            child: Text(
                              User().company?.description ?? "",
                              style: TextStyle(
                                  color: ds.DesignColor.grey.grey_3,
                                  fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            margin:
                                const EdgeInsets.all(ds.Spacing.smallSpacing),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ds.Button.fill(
                                  text: labelsProvider.getText(
                                      key:
                                          "onboarding.companyInformationPage.agreeButton"),
                                  outlineBorder: true,
                                  disableColor: (_selection == true
                                      ? (themeProvider.themeMode ==
                                              ThemeMode.dark
                                          ? ds.DesignColor.primary.dark
                                          : ds.DesignColor.primary.main)
                                      : (themeProvider.themeMode ==
                                              ThemeMode.dark
                                          ? ds.DesignColor.grey.grey_9
                                          : ds.DesignColor.grey.grey_1)),
                                  textColor: _selection == true
                                      ? ds.DesignColor.grey.grey_1
                                      : ds.DesignColor.primary.main,
                                  backgroundColor: (_selection == true
                                      ? (themeProvider.themeMode ==
                                              ThemeMode.dark
                                          ? ds.DesignColor.primary.dark
                                          : ds.DesignColor.primary.main)
                                      : (themeProvider.themeMode ==
                                              ThemeMode.dark
                                          ? ds.DesignColor.grey.grey_9
                                          : ds.DesignColor.grey.grey_1)),
                                  size: ds.ButtonSize.small,
                                  onPressed: _nextButtonClicked
                                      ? null
                                      : () => onSelectOption(
                                          _selection == true ? null : true),
                                ),
                                ds.Button.fill(
                                  text: labelsProvider.getText(
                                      key:
                                          "onboarding.companyInformationPage.disagreeButton"),
                                  outlineBorder: true,
                                  disableColor: (_selection == false
                                      ? (themeProvider.themeMode ==
                                              ThemeMode.dark
                                          ? ds.DesignColor.primary.dark
                                          : ds.DesignColor.primary.main)
                                      : (themeProvider.themeMode ==
                                              ThemeMode.dark
                                          ? ds.DesignColor.grey.grey_9
                                          : ds.DesignColor.grey.grey_1)),
                                  textColor: _selection == false
                                      ? ds.DesignColor.grey.grey_1
                                      : ds.DesignColor.primary.main,
                                  backgroundColor: (_selection == false
                                      ? (themeProvider.themeMode ==
                                              ThemeMode.dark
                                          ? ds.DesignColor.primary.dark
                                          : ds.DesignColor.primary.main)
                                      : (themeProvider.themeMode ==
                                              ThemeMode.dark
                                          ? ds.DesignColor.grey.grey_9
                                          : ds.DesignColor.grey.grey_1)),
                                  size: ds.ButtonSize.small,
                                  onPressed: _nextButtonClicked
                                      ? null
                                      : () => onSelectOption(
                                          _selection == false ? null : false),
                                ),
                              ],
                            ),
                          ),
                          TextFormField(
                            maxLines: 8,
                            minLines: 8,
                            controller: companyInfoTextEditingController,
                            validator: (value) {
                              if (_selection != false) return null;
                              if (value == null || value.isEmpty) {
                                return labelsProvider.getText(
                                    key:
                                        "onboarding.companyInformationPage.userClarificationInputValidatorErrorMessage");
                              }
                              return null;
                            },
                            readOnly: _nextButtonClicked,
                            focusNode: focusNode,
                            style: TextStyle(
                                color: themeProvider.themeMode == ThemeMode.dark
                                    ? ds.DesignColor.grey.grey_1
                                    : ds.DesignColor.grey.grey_9),
                            onTapOutside: (_) => focusNode.unfocus(),
                            decoration: InputDecoration(
                                hintText: labelsProvider.getText(
                                    key:
                                        "onboarding.companyInformationPage.userClarificationInputHintText"),
                                hintStyle: TextStyle(
                                    color: ds.DesignColor.grey.grey_3),
                                filled: true,
                                enabled: true,
                                fillColor:
                                    themeProvider.themeMode == ThemeMode.dark
                                        ? ds.DesignColor.grey.grey_9
                                        : ds.DesignColor.grey.grey_1,
                                border: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(6.0),
                                    borderSide: BorderSide(
                                        color: ds.DesignColor.grey.grey_3))),
                          ),
                          Padding(
                              padding:
                                  const EdgeInsets.all(ds.Spacing.smallSpacing),
                              child: ds.Button.fill(
                                text: labelsProvider.getText(
                                    key: "onboarding.nextButton"),
                                backgroundColor:
                                    themeProvider.themeMode == ThemeMode.dark
                                        ? ds.DesignColor.primary.dark
                                        : ds.DesignColor.primary.main,
                                size: ds.ButtonSize.small,
                                onPressed: _nextButtonClicked
                                    ? null
                                    : () => onNextButtonClick(),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomBarWidget: SizedBox(
          height: 20,
          child: _nextButtonClicked
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
