import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mojodex_mobile/src/models/user/user.dart';
import 'package:mojodex_mobile/src/views/onboarding/select_category_view.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_list/user_task_execution_list.dart';
import 'package:provider/provider.dart';

import '../../models/language/system_language.dart';
import '../widgets/terms_and_conditions.dart';
import 'company_information_view.dart';
import 'progress_indicator_view.dart';
import 'web_url_input_view.dart';

class OnboardingPagesController extends StatefulWidget {
  static String routeName = "onboarding";
  const OnboardingPagesController({super.key});

  @override
  State<OnboardingPagesController> createState() =>
      _OnboardingPagesController();
}

class _OnboardingPagesController extends State<OnboardingPagesController> {
  final _controller = PageController(initialPage: 0, keepPage: true);
  late int _nTotalPages;

  void nextPage() {
    if (_getCurrentPage() == _nTotalPages - 1) {
      completeOnboarding();
      return;
    }
    _controller.nextPage(
        duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
  }

  void previousPage() {
    _controller.previousPage(
        duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
  }

  int _getCurrentPage() {
    return _controller.page!.round();
  }

  void goToPage({int? exactPage, int? nPagesAhead, int? nPagesBack}) {
    if (exactPage != null) {
      _controller.jumpToPage(exactPage);
      return;
    }
    if (nPagesAhead != null) {
      int exactPage = _getCurrentPage() + nPagesAhead;
      if (exactPage >= _nTotalPages) {
        completeOnboarding();
        return;
      }
      return;
    }
    if (nPagesBack != null) {
      _controller.jumpToPage(_getCurrentPage() - nPagesBack);
      return;
    }
  }

  Future<bool> completeOnboarding() async {
    if (await User().setOnboardingPresented()) {
      context.goNamed(UserTaskExecutionsListView.routeName);
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final labelsProvider = Provider.of<SystemLanguage>(context);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!User().agreeTermsConditions) {
        TermsAndConditionsTile().show(context, labelsProvider);
      }
    });
    List<Widget> pages = [
      if (User().roleManager.currentRoles != null)
        SelectCategoryView(
          nextPage: nextPage,
        ),
      WebUrlInputView(
          nextPage: nextPage, previousPage: previousPage, goToPage: goToPage),
      ProgressIndicatorView(),
      CompanyInformationView(nextPage: nextPage),
      /* GoalsSelectionView(completeOnboarding: completeOnboarding)*/
    ];

    _nTotalPages = pages.length;

    return WillPopScope(
      onWillPop: () async => false,
      child: PageView(
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
          children: pages),
    );
  }
}
