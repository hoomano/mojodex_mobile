part of design_system;

enum PillsType { soft, fill }

enum _PillsColor { primary, dark, light }

class Pills extends StatelessWidget {
  final String? text;
  final bool visibility;
  final Color? textColor;
  final PillsType type;
  final _PillsColor _color;
  final Widget child;
  final AlignmentDirectional alignment;

  const Pills.primary(
      {super.key,
      this.text,
      required this.type,
      required this.child,
      required this.alignment,
      this.visibility = true,
      this.textColor})
      : _color = _PillsColor.primary;

  const Pills.dark(
      {super.key,
      this.text,
      required this.type,
      required this.child,
      required this.alignment,
      this.visibility = true,
      this.textColor})
      : _color = _PillsColor.dark;

  const Pills.light(
      {super.key,
      this.text,
      required this.type,
      required this.child,
      required this.alignment,
      this.visibility = true,
      this.textColor})
      : _color = _PillsColor.light;

  @override
  Widget build(BuildContext context) {
    switch (_color) {
      case _PillsColor.primary:
        {
          if (type == PillsType.soft) {
            return Badge(
              alignment: alignment,
              backgroundColor: DesignColor.primary.light,
              textColor: textColor ?? DesignColor.primary.dark,
              largeSize: 15,
              padding: const EdgeInsets.symmetric(
                horizontal: 5),
              label: text!=null 
                ? Text(
                  text!,
                  style: const TextStyle(fontSize: 10, fontFamily: 'Roboto'))
                : null,
              isLabelVisible: visibility,
              child: child,
            );
          }
          return Badge(
            alignment: alignment,
            backgroundColor: DesignColor.primary.main,
            textColor: textColor ?? DesignColor.white,
            largeSize: 15,
            padding: const EdgeInsets.symmetric(
              horizontal: 5),
            label: text!=null 
              ? Text(
                text!,
                style: const TextStyle(fontSize: 10, fontFamily: 'Roboto'))
              : null,
            isLabelVisible: visibility,
            child: child,
          );
        }
      case _PillsColor.dark:
        {
          if (type == PillsType.soft) {
            return Badge(
              alignment: alignment,
              backgroundColor: DesignColor.grey.grey_3,
              textColor: textColor ?? DesignColor.grey.grey_7,
              largeSize: 15,
              padding: const EdgeInsets.symmetric(
                horizontal: 5),
              label: text!=null 
                ? Text(
                  text!,
                  style: const TextStyle(fontSize: 10, fontFamily: 'Roboto'))
                : null,
              isLabelVisible: visibility,
              child: child,
            );
          }
          return Badge(
            alignment: alignment,
            backgroundColor: DesignColor.grey.grey_5,
            textColor: textColor ?? DesignColor.white,
            largeSize: 15,
            padding: const EdgeInsets.symmetric(
              horizontal: 5),
            label: text!=null 
              ? Text(
                text!,
                style: const TextStyle(fontSize: 10, fontFamily: 'Roboto'))
              : null,
              isLabelVisible: visibility,
            child: child,
          );
        }
      default:
        {
          if (type == PillsType.soft) {
            return Badge(
              alignment: alignment,
              backgroundColor: DesignColor.grey.grey_1,
              textColor: textColor ?? DesignColor.grey.grey_7,
              largeSize: 15,
              padding: const EdgeInsets.symmetric(
                horizontal: 5),
              label: text!=null 
                ? Text(
                  text!,
                  style: const TextStyle(fontSize: 10, fontFamily: 'Roboto'))
                : null,
              isLabelVisible: visibility,
              child: child,
            );
          }
          return Badge(
            alignment: alignment,
            backgroundColor: DesignColor.grey.grey_1,
            textColor: textColor ?? DesignColor.black,
            largeSize: 15,
              padding: const EdgeInsets.symmetric(
                horizontal: 5),
            label: text!=null 
              ? Text(
                text!,
                style: const TextStyle(fontSize: 10, fontFamily: 'Roboto'))
              : null,
              isLabelVisible: visibility,
            child: child,
          );
        }
    }
  }
}
