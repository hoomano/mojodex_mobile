import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mojodex_mobile/src/views/login_view/provider_signin_button.dart';

import '../../models/user/user.dart';

class GoogleSignInButton extends StatelessWidget {
  final Function() onLoginConfirmation;
  final Function(Map<String, dynamic>?, BuildContext) onLoginFailure;
  const GoogleSignInButton(
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
          GoogleSignIn googleSignIn = GoogleSignIn(
            clientId: defaultTargetPlatform == TargetPlatform.android
                ? dotenv.env['GOOGLE_ANDROID_CLIENT_ID']!
                : dotenv.env['GOOGLE_IOS_CLIENT_ID']!,
            serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
            scopes: ['email', 'openid', 'profile'],
          );
          GoogleSignInAccount? account = await googleSignIn.signIn();
          GoogleSignInAuthentication? auth = await account?.authentication;
          if (auth == null || auth.idToken == null) return null;
          return await User().signInWithGoogle(account!.email, auth!.idToken!);
        },
        logoName: 'google_logo.png',
        providerName: "Google");
  }
}
