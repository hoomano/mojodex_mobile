import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/views/skeletons/skeleton_item.dart';

import '../../../DS/design_system.dart' as ds;

class SkeletonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _skeletonView();
  }

  Widget _skeletonView() => Container(
        margin: const EdgeInsets.only(
            top: ds.Spacing.mediumPadding,
            left: ds.Spacing.smallPadding,
            right: ds.Spacing.smallPadding),
        child: ListView.builder(
          // padding: padding,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 50,
          itemBuilder: (context, index) => const Padding(
              padding: EdgeInsets.all(ds.Spacing.smallPadding),
              child: SkeletonCard()),
        ),
      );
}
