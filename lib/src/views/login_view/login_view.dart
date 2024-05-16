import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mojodex_mobile/src/views/login_view/google_signin.dart';
import 'package:mojodex_mobile/src/views/login_view/other_providers_divider.dart';
import 'package:mojodex_mobile/src/views/widgets/common_scaffold.dart';

import '../../../DS/design_system.dart' as ds;
import '../../app_router.dart';
import '../../models/user/user.dart';
import '../onboarding/onboarding_page_controller.dart';

class LoginView extends StatelessWidget {
  final Widget emailPasswordWidget;
  LoginView({Key? key, required this.emailPasswordWidget}) : super(key: key);

  static void onLoginFailure(
      Map<String, dynamic>? userData, BuildContext context) {
    ds.Alerts.danger(
        context,
        Text(
            "🫣 ${userData != null ? userData['error'] : 'Oops, something weird has happened'}",
            style: TextStyle(fontSize: ds.TextFontSize.h4)),
        hasLeading: false,
        subtitle: const Text("Try again or contact us by email for help."));
  }

  static Future<void> onLoginConfirmation() async {
    await User().login();
    if (User().onboardingPresented) {
      AppRouter().goRouter.go(AppRouter().initialLocation);
    } else {
      AppRouter().goRouter.goNamed(OnboardingPagesController.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MojodexScaffold(
      appBarTitle: '',
      body: Column(
        children: [
          emailPasswordWidget,
          const OtherProvidersDivider(),
          if (dotenv.env.containsKey("GOOGLE_SERVER_CLIENT_ID"))
            GoogleSignInButton(
              onLoginConfirmation: onLoginConfirmation,
              onLoginFailure: onLoginFailure,
            )
        ],
      ),
      safeAreaOverflow: false,
    );
  }
}
