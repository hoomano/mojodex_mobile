import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../DS/design_system.dart' as ds;

class SkeletonList extends StatelessWidget {
  int itemCount;
  SkeletonList({this.itemCount = 50, Key? key}) : super(key: key);

  Widget getSkeletonItem(BuildContext context) {
    return Skeleton.leaf(
      child: Card(
          child: Container(height: MediaQuery.of(context).size.height / 8.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        begin: const Alignment(-2.4, -0.2),
        end: const Alignment(2.4, 0.2),
        baseColor: ds.DesignColor.grey.grey_1,
        highlightColor: ds.DesignColor.white,
      ),
      child: itemCount == 1
          ? getSkeletonItem(context)
          : Container(
              margin: const EdgeInsets.only(
                  top: ds.Spacing.mediumPadding,
                  left: ds.Spacing.smallPadding,
                  right: ds.Spacing.smallPadding),
              child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: itemCount,
                  itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.all(ds.Spacing.smallPadding),
                      child: getSkeletonItem(context))),
            ),
    );
  }
}
