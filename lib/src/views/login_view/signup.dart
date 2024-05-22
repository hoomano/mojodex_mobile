import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mojodex_mobile/src/views/login_view/email_password_signup.dart';
import 'package:mojodex_mobile/src/views/login_view/login_view.dart';
import 'package:mojodex_mobile/src/views/widgets/common_scaffold.dart';

import 'google_signin.dart';
import 'other_providers_divider.dart';

class SignUpView extends StatelessWidget {
  static const routeName = 'signup';
  SignUpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MojodexScaffold(
      appBarTitle: '',
      body: Column(
        children: [
          const EmailPasswordSignUp(
              onLoginConfirmation: LoginView.onLoginConfirmation,
              onLoginFailure: LoginView.onLoginFailure),
          const OtherProvidersDivider(),
          if (dotenv.env.containsKey("GOOGLE_SERVER_CLIENT_ID"))
            GoogleSignInButton(
              onLoginConfirmation: LoginView.onLoginConfirmation,
              onLoginFailure: LoginView.onLoginFailure,
            )
        ],
      ),
      safeAreaOverflow: false,
    );
  }
}
