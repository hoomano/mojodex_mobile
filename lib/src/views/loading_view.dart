import 'package:flutter/material.dart';
import 'package:mojodex_mobile/DS/theme/themes.dart';
import 'package:mojodex_mobile/src/views/widgets/common_scaffold.dart';
import 'package:provider/provider.dart';

import '../../../DS/design_system.dart' as ds;

class LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MojodexScaffold(
        appBarTitle: "New task",
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "✍️ Preparing new task...",
                  style: TextStyle(fontSize: ds.TextFontSize.h6),
                ),
                ds.Space.verticalLarge,
                LinearProgressIndicator(
                  color: ds.DesignColor.primary.main,
                  backgroundColor: themeProvider.themeMode == ThemeMode.dark 
                    ? ds.DesignColor.grey.grey_7
                    : ds.DesignColor.grey.grey_3,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(10),
                )
              ],
            ),
          ),
        ),
        safeAreaOverflow: true);
  }
}
