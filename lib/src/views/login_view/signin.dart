import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/views/login_view/email_password_signin.dart';

import 'login_view.dart';

class SignInView extends StatelessWidget {
  static const routeName = 'signin';
  SignInView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoginView(
      emailPasswordWidget: EmailPasswordSignIn(
          onLoginConfirmation: LoginView.onLoginConfirmation,
          onLoginFailure: LoginView.onLoginFailure),
    );
  }
}
