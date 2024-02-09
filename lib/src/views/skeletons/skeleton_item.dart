import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';

import '../../../DS/design_system.dart' as ds;
import '../../../DS/theme/themes.dart';

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return SkeletonTheme(
      shimmerGradient: LinearGradient(
        begin: const Alignment(-2.4, -0.2),
        end: const Alignment(2.4, 0.2),
        tileMode: TileMode.clamp,
        colors: themeProvider.themeMode == ThemeMode.dark
            ? [
                ds.DesignColor.grey.grey_5,
                ds.DesignColor.grey.grey_7,
                ds.DesignColor.grey.grey_5
              ]
            : [
                ds.DesignColor.white,
                ds.DesignColor.grey.grey_1,
                ds.DesignColor.white
              ],
        stops: const [
          0.1,
          0.5,
          0.9,
        ],
      ),
      child: SkeletonItem(
          child: Column(
        children: [
          SkeletonAvatar(
            style: SkeletonAvatarStyle(
              borderRadius: BorderRadius.circular(8.0),
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 8.5,
            ),
          ),
        ],
      )),
    );
  }
}
