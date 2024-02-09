part of design_system;

class Spacing {
  static const double base = 4;
  static const double smallPadding = 8;
  static const double mediumPadding = 16;
  static const double largePadding = 24;
  static const double smallSpacing = 32;
  static const double mediumSpacing = 64;
  static const double largeSpacing = 128;
  static const double extraLargeSpacing = 192;
}


class Space extends StatelessWidget {
  static const Space verticalBase = Space(vertical: Spacing.base);
  static const Space verticalSmall = Space(vertical: Spacing.smallPadding);
  static const Space verticalMedium = Space(vertical: Spacing.mediumPadding);
  static const Space verticalLarge = Space(vertical: Spacing.largePadding);
  static const Space horizontalBase = Space(horizontal: Spacing.base);
  static const Space horizontalSmall = Space(horizontal: Spacing.smallPadding);
  static const Space horizontalMedium = Space(horizontal: Spacing.mediumPadding);
  static const Space horizontalLarge = Space(horizontal: Spacing.largePadding);

  final double vertical;
  final double horizontal;

  const Space({
    Key? key,
    this.vertical = 0,
    this.horizontal = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: vertical,
      width: horizontal,
      color: Colors.transparent,
    );
  }
}
