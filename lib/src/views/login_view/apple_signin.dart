import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/views/login_view/provider_signin_button.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../models/user/user.dart';

class AppleSignInButton extends StatelessWidget {
  final Function() onLoginConfirmation;
  final Function(Map<String, dynamic>?, BuildContext) onLoginFailure;
  const AppleSignInButton(
      {Key? key,
      required this.onLoginConfirmation,
      required this.onLoginFailure})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderSignInButton(
        onLoginConfirmation: onLoginConfirmation,
        onLoginFailure: onLoginFailure,
        providerSignIn: () async {
          print('Apple Sign In');
          AuthorizationCredentialAppleID credential =
              await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
            ],
          );
          return await User().signInWithApple(
              credential.email ?? "", credential.authorizationCode);
        },
        logoName: 'apple_logo.png',
        providerName: "Apple");
  }
}
