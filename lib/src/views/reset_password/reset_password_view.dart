import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/constants/constants.dart';
import 'package:mojodex_mobile/src/views/login_view/signin.dart';
import 'package:mojodex_mobile/src/views/widgets/common_scaffold.dart';
import 'package:provider/provider.dart';

import '../../../DS/design_system.dart' as ds;
import '../../../DS/theme/themes.dart';
import '../../app_router.dart';
import '../../models/user/user.dart';

class ResetPasswordView extends StatefulWidget {
  static const routeName = 'reset-password';
  final String token;
  ResetPasswordView({required this.token, Key? key}) : super(key: key);

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _processing = false;
  bool _confirmed = false;
  bool _failure = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _processing = true;
      });
      // Passwords match, perform password reset logic here
      String newPassword = _passwordController.text;
      bool success = await User()
          .resetPassword(token: widget.token, newPassword: newPassword);
      setState(() {
        _processing = false;
        _confirmed = success;
        _failure = !success;
      });
      if (_confirmed) {
        // await 2 seconds to show everything worked
        await Future.delayed(const Duration(seconds: 2));
        AppRouter().goRouter.pushReplacementNamed(SignInView.routeName);
      } else if (_failure) {
        ds.Alerts.danger(
            context,
            const Text("🫣 Password reset failed",
                style: TextStyle(fontSize: ds.TextFontSize.h4)),
            hasLeading: false,
            subtitle: const Text("Try again or contact us by email for help."));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MojodexScaffold(
      appBarTitle: '',
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(ds.Spacing.largePadding),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Mojodex logo
                Image.asset(
                  Constants.logoPath,
                  width: 70,
                  height: 70,
                ),
                ds.Space.verticalLarge,
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: ds.Spacing.mediumPadding),
                  child: Text(
                    "Set a new password",
                    style: TextStyle(
                        fontSize: ds.TextFontSize.h4,
                        color: themeProvider.themeMode == ThemeMode.dark
                            ? ds.DesignColor.grey.grey_1
                            : ds.DesignColor.grey.grey_9),
                  ),
                ),
                ds.Space.verticalLarge,
                // Form with 2 fields: password and confirm password that are required and must match
                TextFormField(
                  enabled: !_processing && !_confirmed,
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      hintText: 'Enter your new password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: ds.DesignColor.primary.main))),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    return null;
                  },
                ),
                ds.Space.verticalLarge,
                TextFormField(
                  enabled: !_processing && !_confirmed,
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      hintText: 'Confirm your new password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: ds.DesignColor.primary.main))),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    } else if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                ds.Space.verticalLarge,
                _processing
                    ? SizedBox(
                        height: ds.TextFontSize.h1,
                        width: ds.TextFontSize.h1,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _confirmed
                        ? SizedBox(
                            height: ds.TextFontSize.h1,
                            width: ds.TextFontSize.h1,
                            child: ds.DesignIcon.circleCheck(
                              fit: BoxFit.cover,
                              color: ds.DesignColor.status.success,
                              size: ds.TextFontSize.h4,
                            ),
                          )
                        : ds.Button.fill(
                            text: 'Reset Password',
                            onPressed: _submitForm,
                          ),
              ],
            ),
          ),
        ),
      ),
      safeAreaOverflow: false,
    );
  }
}
