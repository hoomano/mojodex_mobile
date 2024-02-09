import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/models/language/system_language.dart';
import 'package:mojodex_mobile/src/views/widgets/status_bar/animated_card.dart';
import 'package:provider/provider.dart';

import '../../../DS/design_system.dart' as ds;
import '../../../DS/theme/themes.dart';
import '../../models/error_notifier.dart';
import '../../models/user/user.dart';

class MojodexScaffold extends StatefulWidget {
  final String appBarTitle;
  final bool automaticallyImplyLeading;
  final Widget body;
  final bool safeAreaOverflow;
  final Widget? drawer;
  final PreferredSizeWidget? appBarBottom;
  final Widget? bottomBarWidget;
  final Widget? appBarAction;
  final bool resizeToAvoidBottomInset;

  MojodexScaffold(
      {Key? key,
      required this.appBarTitle,
      required this.body,
      required this.safeAreaOverflow,
      this.drawer,
      this.appBarBottom,
      this.bottomBarWidget,
      this.appBarAction,
      this.automaticallyImplyLeading = true,
      this.resizeToAvoidBottomInset = true})
      : super(key: key);

  static bool _hasConsumedError = false;
  static void consumeError() {
    _hasConsumedError = true;
    ErrorNotifier().consumeError();
    _hasConsumedError = false;
  }

  @override
  State<MojodexScaffold> createState() => _MojodexScaffoldState();
}

class _MojodexScaffoldState extends State<MojodexScaffold> {
  bool _freezeScreen = false;
  SnackBar _buildSnackbar(String message, bool success, bool isDark) {
    return SnackBar(
      backgroundColor:
          isDark ? ds.DesignColor.grey.grey_7 : ds.DesignColor.grey.grey_1,
      content: Text(
        message,
        style: TextStyle(
            color: isDark
                ? ds.DesignColor.grey.grey_1
                : ds.DesignColor.grey.grey_7),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);

    return StreamBuilder<String?>(
        stream: ErrorNotifier().errorStream,
        builder: (context, snapshot) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (snapshot.hasData && snapshot.data != null) {
              if (MojodexScaffold._hasConsumedError) {
                return;
              }
              //  String errorMessage = snapshot.data!;
              final themeProvider =
                  Provider.of<ThemeProvider>(context, listen: false);
              SnackBar snackbar = _buildSnackbar(
                  labelsProvider.getText(
                      key: "errorMessages.globalSnackBarMessage"),
                  false,
                  themeProvider.themeMode == ThemeMode.dark);
              ScaffoldMessenger.of(context).showSnackBar(snackbar);
              // drop the error
              MojodexScaffold.consumeError();
            }
          });
          return AbsorbPointer(
            absorbing: _freezeScreen,
            child: Scaffold(
              resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
              backgroundColor: themeProvider.themeMode == ThemeMode.dark
                  ? ds.DesignColor.grey.grey_9
                  : ds.DesignColor.white,
              appBar: AppBar(
                iconTheme: const IconThemeData(
                  color: ds.DesignColor.white, //change your color here
                ),
                automaticallyImplyLeading: widget.automaticallyImplyLeading,
                leading: widget.drawer != null
                    // Allows to place a pill on the leading icon
                    // when the leading is actually a drawer
                    ? ValueListenableBuilder(
                        valueListenable: User().todoList.nNotReadTodosNotifier,
                        builder: (context, notReadTodos, child) {
                          return IconButton(
                              onPressed: () =>
                                  Scaffold.of(context).openDrawer(),
                              icon: ds.Pills.primary(
                                  type: ds.PillsType.fill,
                                  alignment: AlignmentDirectional.topEnd,
                                  visibility: User().todoList.nNotReadTodos > 0,
                                  child: const Padding(
                                    padding: EdgeInsets.all(ds.Spacing.base),
                                    child: Icon(Icons.menu,
                                        color: ds.DesignColor.white),
                                  )));
                        })
                    : null,
                title: Text(widget.appBarTitle,
                    style: TextStyle(color: ds.DesignColor.white)),
                backgroundColor: ds.DesignColor.grey.grey_7,
                bottom: widget.appBarBottom,
                actions: [
                  if (widget.appBarAction != null) widget.appBarAction!
                ],
              ),
              body: ColorfulSafeArea(
                  overflowRules: OverflowRules.all(widget.safeAreaOverflow),
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      AnimatedStatusBar(
                          onTaskCardSelected: () {
                            setState(() {
                              _freezeScreen = !_freezeScreen;
                            });
                          },
                          name: widget.appBarTitle),
                      Expanded(child: widget.body),
                    ],
                  )),
              drawer: widget.drawer,
              bottomNavigationBar: widget.bottomBarWidget,
            ),
          );
        });
  }
}
