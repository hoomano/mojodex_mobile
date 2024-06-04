import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/models/session/home_chat_session.dart';
import 'package:mojodex_mobile/src/views/home_screen/welcome_message.dart';
import 'package:mojodex_mobile/src/views/widgets/common_scaffold.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../DS/theme/themes.dart';
import '../../models/home_chat/home_chat.dart';
import '../drawer/app_drawer.dart';
import '../user_task_execution_view/chat_view/chat_bottom_bar.dart';
import '../user_task_execution_view/chat_view/messages_list.dart';

class HomeScreen extends StatelessWidget {
  static String routeName = "home";

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MojodexScaffold(
        appBarTitle: "Home",
        safeAreaOverflow: false,
        drawer: AppDrawer(),
        body: FutureBuilder(
            future: HomeChat().refresh(),
            builder: (context, AsyncSnapshot snapshot) {
              return HomeChat().inError
                  ? Padding(
                      padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            HomeChat().initialMessageHeader,
                            style: TextStyle(
                                color: themeProvider.themeMode == ThemeMode.dark
                                    ? ds.DesignColor.white
                                    : ds.DesignColor.grey.grey_5,
                                fontWeight: FontWeight.bold,
                                fontSize: ds.TextFontSize.h4),
                            textAlign: TextAlign.center,
                          ),
                          ds.Space.verticalLarge,
                          Text(HomeChat().initialMessageBody,
                              style: TextStyle(
                                  color:
                                      themeProvider.themeMode == ThemeMode.dark
                                          ? ds.DesignColor.white
                                          : ds.DesignColor.grey.grey_7,
                                  fontSize: ds.TextFontSize.body1),
                              textAlign: TextAlign.center),
                          ds.Space.verticalLarge,
                        ],
                      ))
                  : ChangeNotifierProvider<HomeChatSession>.value(
                      value: HomeChat().session,
                      child: Consumer<HomeChatSession>(builder:
                          (BuildContext context, HomeChatSession session,
                              Widget? child) {
                        return Column(
                          children: [
                            Expanded(
                              child: session.messages.length < 2
                                  ? WelcomeMessage(session: session)
                                  : MessagesList(
                                      session: session,
                                      onResubmit: session.reSubmit),
                            ),
                            ChatBottomBar(session: session),
                            if (snapshot.connectionState ==
                                ConnectionState.waiting)
                              Padding(
                                padding: const EdgeInsets.all(
                                    ds.Spacing.smallPadding),
                                child: LinearProgressIndicator(
                                  color: ds.DesignColor.primary.main,
                                  backgroundColor:
                                      themeProvider.themeMode == ThemeMode.dark
                                          ? ds.DesignColor.grey.grey_7
                                          : ds.DesignColor.grey.grey_3,
                                ),
                              )
                          ],
                        );
                      }),
                    );
            }));
  }
}
