import 'package:flutter/material.dart';
import 'package:mojodex_mobile/DS/design_system.dart' as ds;
import 'package:mojodex_mobile/src/purchase_manager/product_category.dart';
import 'package:mojodex_mobile/src/views/widgets/common_scaffold.dart';
import 'package:provider/provider.dart';

import '../../../DS/theme/themes.dart';
import '../../models/language/system_language.dart';
import '../../models/user/user.dart';

class SelectCategoryView extends StatefulWidget {
  final Function() nextPage;

  late List<ProductCategory> categories;

  SelectCategoryView({required this.nextPage, Key? key}) : super(key: key) {
    categories = User().purchaseManager.productCategories;
  }

  @override
  State<SelectCategoryView> createState() => _SelectCategoryViewState();
}

class _SelectCategoryViewState extends State<SelectCategoryView> {
  bool _nextButtonClicked = false;

  int? _selectedCategoryIndex;

  Future<bool> setCategory(int categoryPk) async {
    return await User().purchaseManager.activateFreeTrial(categoryPk);
  }

  void onNextButtonClick(BuildContext context) async {
    setState(() => _nextButtonClicked = true);

    int category = widget.categories[_selectedCategoryIndex!].productCategoryPk;
    bool success = await setCategory(category);
    setState(() => _nextButtonClicked = false);
    if (success) {
      widget.nextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);
    return MojodexScaffold(
      appBarTitle: "",
      automaticallyImplyLeading: false,
      resizeToAvoidBottomInset: false,
      safeAreaOverflow: false,
      body: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: ds.Spacing.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
                child: Text(
                    labelsProvider.getText(
                        key: 'onboarding.categorySelection.emoji'),
                    style: TextStyle(fontSize: ds.TextFontSize.h1))),
            Flexible(
              child: Text(
                  labelsProvider.getText(
                      key: 'onboarding.categorySelection.title'),
                  style: TextStyle(
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? ds.DesignColor.grey.grey_1
                          : ds.DesignColor.grey.grey_9,
                      fontSize: ds.TextFontSize.h3),
                  textAlign: TextAlign.center),
            ),
            Flexible(
              child: Text(
                  labelsProvider.getText(
                      key: 'onboarding.categorySelection.content'),
                  style: TextStyle(
                      color: ds.DesignColor.grey.grey_3,
                      fontSize: ds.TextFontSize.body2),
                  textAlign: TextAlign.center),
            ),
            Flexible(
              child: Text(
                  labelsProvider.getText(
                      key: 'onboarding.categorySelection.question'),
                  style: TextStyle(
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? ds.DesignColor.grey.grey_1
                          : ds.DesignColor.grey.grey_9,
                      fontSize: ds.TextFontSize.h5),
                  textAlign: TextAlign.center),
            ),
            Flexible(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: ds.Spacing.largePadding),
                child: ListView.builder(
                    itemCount: widget.categories.length,
                    itemBuilder: (BuildContext context, int index) => Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: ds.Spacing.smallPadding),
                          child: _selectedCategoryIndex == index
                              ? ds.Button.fill(
                                  backgroundColor:
                                      themeProvider.themeMode == ThemeMode.dark
                                          ? ds.DesignColor.primary.dark
                                          : ds.DesignColor.primary.main,
                                  fontSize: ds.TextFontSize.body2,
                                  maxLine: 5,
                                  minWidth: MediaQuery.of(context).size.width,
                                  onPressed: () {},
                                  padding:
                                      const EdgeInsets.all(ds.Spacing.base),
                                  text:
                                      "${widget.categories[index].name} ${widget.categories[index].emoji}\n\n"
                                      "${widget.categories[index].description}")
                              : ds.Button.outline(
                                  disableColor:
                                      themeProvider.themeMode == ThemeMode.dark
                                          ? ds.DesignColor.grey.grey_9
                                          : ds.DesignColor.grey.grey_1,
                                  backgroundColor:
                                      themeProvider.themeMode == ThemeMode.dark
                                          ? ds.DesignColor.grey.grey_9
                                          : ds.DesignColor.grey.grey_1,
                                  fontSize: ds.TextFontSize.body2,
                                  maxLine: 5,
                                  minWidth: MediaQuery.of(context).size.width,
                                  onPressed: (_nextButtonClicked
                                      ? null
                                      : () => setState(() =>
                                          _selectedCategoryIndex = index)),
                                  padding:
                                      const EdgeInsets.all(ds.Spacing.base),
                                  text:
                                      "${widget.categories[index].name} ${widget.categories[index].emoji}\n\n"
                                      "${widget.categories[index].description}"),
                        )),
              ),
            ),
            ds.Button.fill(
              backgroundColor: themeProvider.themeMode == ThemeMode.dark
                  ? ds.DesignColor.primary.dark
                  : ds.DesignColor.primary.main,
              text: labelsProvider.getText(key: 'onboarding.nextButton'),
              size: ds.ButtonSize.small,
              onPressed: _selectedCategoryIndex == null
                  ? null
                  : () => onNextButtonClick(context),
            )
          ],
        ),
      ),
    );
  }
}
