import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/language/system_language.dart';
import 'package:mojodex_mobile/src/views/settings_view/plan_view/profile_card.dart';
import 'package:mojodex_mobile/src/views/settings_view/plan_view/role_activation_badge.dart';
import 'package:mojodex_mobile/src/views/settings_view/plan_view/role_usage.dart';
import 'package:mojodex_mobile/src/views/widgets/common_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../../DS/theme/themes.dart';
import '../../../role_manager/role_manager.dart';

class PlanView extends StatelessWidget {
  static String routeName = "plan";
  final Logger logger = Logger('PlanView');

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);
    return MojodexScaffold(
        appBarTitle: labelsProvider.getText(key: "plan.appBarTitle"),
        safeAreaOverflow: false,
        body: Consumer<RoleManager>(builder: (context, roleManager, child) {
          if (roleManager.currentRoles == null) {
            return const PlanBannerSkeleton();
          }

          List<Widget> currentRoles = roleManager.currentRoles!
              .map((role) => ProfileCard(
                    profile: role.profile,
                    child: Column(
                      children: [
                        RoleActivationBadge(active: true),
                        ds.Space.verticalLarge,
                        if (role.profile.nValidityDays != null &&
                            role.profile.nTasksLimit != null)
                          RoleUsage(role: role)
                      ],
                    ),
                  ))
              .toList();

          List<Widget> expiredRoles = roleManager.expiredRoles == null
              ? []
              : roleManager.expiredRoles!
                  .map((role) => ProfileCard(
                        profile: role.profile,
                        child: RoleActivationBadge(active: false),
                      ))
                  .toList();

          List<Widget> availableProfiles = roleManager.availableProfiles
              .map((profile) => ProfileCard(profile: profile))
              .toList();

          return Center(
            child: Padding(
                padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          labelsProvider.getText(key: "plan.title"),
                          style: TextStyle(
                            fontSize: ds.TextFontSize.h3,
                            color: themeProvider.themeMode == ThemeMode.dark
                                ? ds.DesignColor.grey.grey_1
                                : ds.DesignColor.grey.grey_9,
                          ),
                        ),
                        ds.Space.verticalLarge,
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            labelsProvider.getText(key: "plan.currentPlans"),
                            style: TextStyle(
                              fontSize: ds.TextFontSize.h3,
                              color: themeProvider.themeMode == ThemeMode.dark
                                  ? ds.DesignColor.grey.grey_1
                                  : ds.DesignColor.grey.grey_9,
                            ),
                          ),
                        ),
                        ds.Space.verticalLarge,
                      ]
                        ..addAll(currentRoles)
                        ..addAll(expiredRoles)
                        ..addAll([
                          ds.Space.verticalLarge,
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              labelsProvider.getText(key: "plan.updatePlan"),
                              style: TextStyle(
                                fontSize: ds.TextFontSize.h3,
                                color: themeProvider.themeMode == ThemeMode.dark
                                    ? ds.DesignColor.grey.grey_1
                                    : ds.DesignColor.grey.grey_9,
                              ),
                            ),
                          ),
                          ds.Space.verticalLarge,
                        ])
                        ..addAll(availableProfiles)),
                )),
          );
        }));
  }
}

class PlanBannerSkeleton extends StatelessWidget {
  const PlanBannerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return SkeletonTheme(
      // themeMode: ThemeMode.light,
      shimmerGradient: LinearGradient(
        colors: [
          themeProvider.themeMode == ThemeMode.dark
              ? ds.DesignColor.grey.grey_5
              : Colors.grey,
          themeProvider.themeMode == ThemeMode.dark
              ? ds.DesignColor.grey.grey_7
              : ds.DesignColor.grey.grey_1,
          themeProvider.themeMode == ThemeMode.dark
              ? ds.DesignColor.grey.grey_5
              : Colors.grey,
        ],
        stops: const [
          0.4,
          0.9,
          0.4,
        ],
      ),
      darkShimmerGradient: LinearGradient(
        colors: [
          ds.DesignColor.grey.grey_3,
          ds.DesignColor.grey.grey_5,
          ds.DesignColor.grey.grey_3,
        ],
        stops: const [
          0.0,
          0.2,
          1,
        ],
        begin: const Alignment(-2.4, -0.2),
        end: const Alignment(2.4, 0.2),
        tileMode: TileMode.clamp,
      ),
      child: Align(
        alignment: Alignment.center,
        child: SkeletonItem(
          child: SkeletonParagraph(
            style: SkeletonParagraphStyle(
                lines: 1,
                spacing: 6,
                lineStyle: SkeletonLineStyle(
                  randomLength: false,
                  height: 40,
                  borderRadius: BorderRadius.circular(8),
                  minLength: MediaQuery.of(context).size.width - 1,
                  maxLength: MediaQuery.of(context).size.width,
                )),
          ),
        ),
      ),
    );
  }
}
