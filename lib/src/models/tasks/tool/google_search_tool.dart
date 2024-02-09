import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/models/tasks/tool/task_tool_query.dart';
import 'package:mojodex_mobile/src/models/tasks/tool/tool.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../DS/design_system.dart' as ds;

class GoogleSearchTool extends Tool {
  GoogleSearchTool()
      : super(name: "Web Search Results", label: "google_search");

  Future<void> _launchURL(BuildContext context, String url) async {
    try {
      await launchUrl(
        Uri.parse(url),
      );
    } catch (e) {
      // An exception is thrown if browser app is not installed on Android device.
      debugPrint(e.toString());
    }
  }

  @override
  Widget getResultWidget(
      {required BuildContext context,
      required TaskToolQuery taskToolQuery,
      int? index,
      int? total}) {
    //title is the concatenation of all taskToolQuery.query values (not keys)
    String title = taskToolQuery.query.values.join(" - ");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: ds.TextFontSize.h6, fontWeight: FontWeight.bold),
        ),
        taskToolQuery.result == null
            ? Container()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: taskToolQuery.result!
                    .map((res) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => _launchURL(context, res["source"]),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: ds.Spacing.smallPadding),
                                child: Text(
                                  res["source"],
                                  style: TextStyle(
                                      fontSize: ds.TextFontSize.body2,
                                      color: ds.DesignColor.primary.main),
                                ),
                              ),
                            ),
                            Text(
                              res["extracted"],
                              style: TextStyle(fontSize: ds.TextFontSize.body2),
                            ),
                          ],
                        ))
                    .toList())
      ],
    );
  }
}
