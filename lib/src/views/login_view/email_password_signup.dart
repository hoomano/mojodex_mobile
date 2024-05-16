import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../DS/design_system.dart' as ds;
import '../../../DS/theme/themes.dart';
import '../../app_router.dart';
import '../../constants/constants.dart';
import '../../models/user/user.dart';

class EmailPasswordSignUp extends StatefulWidget {
  final Function() onLoginConfirmation;
  final Function(Map<String, dynamic>?, BuildContext) onLoginFailure;
  const EmailPasswordSignUp(
      {Key? key,
      required this.onLoginConfirmation,
      required this.onLoginFailure})
      : super(key: key);

  @override
  State<EmailPasswordSignUp> createState() => _EmailPasswordSignUpState();
}

class _EmailPasswordSignUpState extends State<EmailPasswordSignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _processing = false;
  bool _confirmed = false;
  bool _failure = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _processing = true;
      });

      String name = _nameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;
      Map<String, dynamic>? userData =
          await User().signUp(name, email, password);
      bool success = userData != null && !userData.containsKey('error');
      setState(() {
        _processing = false;
        _confirmed = success;
        _failure = !success;
      });
      if (_confirmed) {
        widget.onLoginConfirmation();
      } else if (_failure) {
        widget.onLoginFailure(userData, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Form(
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
                  "Create an account",
                  style: TextStyle(
                      fontSize: ds.TextFontSize.h4,
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? ds.DesignColor.grey.grey_1
                          : ds.DesignColor.grey.grey_9),
                ),
              ),
              ds.Space.verticalLarge,
              TextFormField(
                enabled: !_processing && !_confirmed,
                controller: _nameController,
                decoration: InputDecoration(
                    hintText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: ds.DesignColor.primary.main))),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              ds.Space.verticalLarge,
              // Form with 2 fields: email and password that are required
              TextFormField(
                enabled: !_processing && !_confirmed,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: ds.DesignColor.primary.main))),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              ds.Space.verticalLarge,
              TextFormField(
                enabled: !_processing && !_confirmed,
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: ds.DesignColor.primary.main))),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
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
                          text: 'Sign up',
                          onPressed: _submitForm,
                        ),
              ds.Space.verticalLarge,
              if (!_processing && !_confirmed)
                GestureDetector(
                  child: Text("Already have an account? Sign in",
                      style: TextStyle(
                        color: ds.DesignColor.primary.dark,
                        decoration: TextDecoration.underline,
                      )),
                  onTap: () {
                    AppRouter().goRouter.pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
