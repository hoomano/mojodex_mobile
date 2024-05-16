import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/user/user.dart';

class GoogleSignInButton extends StatefulWidget {
  final Function onLoginConfirmation;
  final Function onLoginFailure;
  GoogleSignInButton(
      {Key? key,
      required this.onLoginConfirmation,
      required this.onLoginFailure})
      : super(key: key);

  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: defaultTargetPlatform == TargetPlatform.android
        ? dotenv.env['GOOGLE_ANDROID_CLIENT_ID']!
        : dotenv.env['GOOGLE_IOS_CLIENT_ID']!,
    serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
    scopes: ['email', 'openid', 'profile'],
  );

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _processing = false;
  bool _confirmed = false;
  bool _failure = false;

  Future<void> _loginWithGoogle() async {
    setState(() {
      _processing = true;
    });

    GoogleSignInAccount? account = await widget.googleSignIn.signIn();
    GoogleSignInAuthentication? auth = await account?.authentication;

    Map<String, dynamic>? userData = (auth != null && auth.idToken != null)
        ? await User().signInWithGoogle(account!.email, auth.idToken!)
        : null;

    bool success = userData != null && !userData.containsKey('error');
    setState(() {
      _processing = false;
      _confirmed = success;
      _failure = !success;
    });
    if (_confirmed) {
      await widget.onLoginConfirmation();
    } else if (_failure) {
      widget.onLoginFailure(userData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _processing
        ? Center(
            child: CircularProgressIndicator(),
          )
        : ElevatedButton(
            onPressed: _loginWithGoogle, child: Text("Google Sign In"));
  }
}
