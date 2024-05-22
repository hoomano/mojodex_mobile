import 'package:flutter/material.dart';

import '../../../DS/design_system.dart' as ds;

class ProviderSignInButton extends StatefulWidget {
  final Function() onLoginConfirmation;
  final Function(Map<String, dynamic>?, BuildContext) onLoginFailure;
  final Future<Map<String, dynamic>?> Function() providerSignIn;
  final String logoName;
  final String providerName;
  const ProviderSignInButton(
      {Key? key,
      required this.onLoginConfirmation,
      required this.onLoginFailure,
      required this.providerSignIn,
      required this.logoName,
      required this.providerName})
      : super(key: key);

  @override
  State<ProviderSignInButton> createState() => _ProviderSignInButtonState();
}

class _ProviderSignInButtonState extends State<ProviderSignInButton> {
  bool _processing = false;
  bool _confirmed = false;
  bool _failure = false;

  Future<void> _loginWithProvider() async {
    setState(() {
      _processing = true;
    });
    Map<String, dynamic>? userData = await widget.providerSignIn();

    bool success = userData != null && !userData.containsKey('error');
    setState(() {
      _processing = false;
      _confirmed = success;
      _failure = !success;
    });
    if (_confirmed) {
      await widget.onLoginConfirmation();
    } else if (_failure) {
      widget.onLoginFailure(userData, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ds.Spacing.largePadding),
      child: _processing
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : MaterialButton(
              onPressed: _loginWithProvider,
              shape: OutlineInputBorder(
                borderSide: BorderSide(
                  color: ds.DesignColor.grey.grey_1,
                  width: 1,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(6)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(ds.Spacing.smallPadding),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/${widget.logoName}',
                      width: 24,
                      height: 24,
                    ),
                    const Spacer(),
                    Text(
                      widget.providerName,
                      style: const TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
    );
  }
}
