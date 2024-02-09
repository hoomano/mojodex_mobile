import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/views/widgets/common_scaffold.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../../DS/theme/themes.dart';
import '../../../models/calendar_manager/calendar_manager.dart';
import '../../../models/language/system_language.dart';

class CalendarSettingsView extends StatefulWidget {
  static String routeName = "calendar";

  const CalendarSettingsView({super.key});

  @override
  State<CalendarSettingsView> createState() => _CalendarSettingsViewState();
}

class _CalendarSettingsViewState extends State<CalendarSettingsView>
    with WidgetsBindingObserver {
  final Logger logger = Logger('CalendarSettingsView');

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      CalendarManager().resetPermission();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);
    return MojodexScaffold(
        appBarTitle: labelsProvider.getText(key: "calendar.appBarTitle"),
        body: FutureBuilder<bool>(
            future: CalendarManager().appHasAccess(),
            builder: (context, AsyncSnapshot<bool> hasAccessSnapshot) {
              if (hasAccessSnapshot.connectionState == ConnectionState.done &&
                  hasAccessSnapshot.data != null) {
                bool hasAccess = hasAccessSnapshot.data!;

                return Column(
                  mainAxisAlignment: hasAccess
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
                      child: Text(
                        hasAccess
                            ? labelsProvider.getText(key: "calendar.hasAccess")
                            : labelsProvider.getText(key: "calendar.noAccess"),
                        style: TextStyle(
                          fontSize: ds.TextFontSize.h4,
                          color: themeProvider.themeMode == ThemeMode.dark
                              ? ds.DesignColor.grey.grey_1
                              : ds.DesignColor.grey.grey_9,
                        ),
                      ),
                    ),
                    !hasAccess
                        ? ds.Button.fill(
                            text: labelsProvider.getText(
                                key: "calendar.grantAccessButton"),
                            onPressed: () async {
                              await openAppSettings();
                            },
                          )
                        : FutureBuilder<List<Calendar>>(
                            future: CalendarManager().allCalendars,
                            builder: (context,
                                AsyncSnapshot<List<Calendar>> snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.data != null) {
                                return Expanded(
                                  child: ListView.builder(
                                      padding: const EdgeInsets.all(
                                          ds.Spacing.mediumPadding),
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        Calendar calendar =
                                            snapshot.data![index];
                                        return CalendarTile(calendar);
                                      }),
                                );
                              } else {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                            },
                          ),
                    Padding(
                      padding: const EdgeInsets.all(ds.Spacing.largePadding),
                      child: ds.Button.fill(
                        text: "OK",
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    )
                  ],
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }),
        safeAreaOverflow: true);
  }
}

class CalendarTile extends StatefulWidget {
  final Calendar calendar;
  const CalendarTile(this.calendar, {Key? key}) : super(key: key);

  @override
  State<CalendarTile> createState() => _CalendarTileState();
}

class _CalendarTileState extends State<CalendarTile> {
  @override
  Widget build(BuildContext context) {
    bool isAuthorized =
        CalendarManager().calendarIsAuthorized(widget.calendar.id!);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Color(widget.calendar.color!),
        radius: 12,
      ),
      title: Text(
        widget.calendar.name!,
        style: TextStyle(
          fontSize: ds.TextFontSize.body2,
          color: isAuthorized
              ? ds.DesignColor.grey.grey_9
              : ds.DesignColor.grey.grey_3,
        ),
      ),
      trailing: Switch(
          value: isAuthorized,
          activeColor: ds.DesignColor.primary.main,
          activeTrackColor: ds.DesignColor.primary.light,
          inactiveTrackColor: ds.DesignColor.grey.grey_1,
          inactiveThumbColor: ds.DesignColor.grey.grey_3,
          onChanged: (value) {
            CalendarManager().changeCalendarAuthorization(widget.calendar.id!);
            setState(() {});
          }),
    );
  }
}
