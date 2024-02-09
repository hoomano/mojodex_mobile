part of design_system;

enum ButtonSize { small, medium, large }

enum _ButtonType { fill, outline, soft }

class Button extends StatelessWidget {
  final _ButtonType _type;

  final ButtonSize size;
  final void Function()? onPressed;
  final String? text;
  final Color? textColor;

  final bool outlineBorder;
  final Color? disableColor;
  final Color? backgroundColor;
  final int? maxLine;
  final double? fontSize;
  final double? minWidth;
  final EdgeInsets? padding;

  const Button.fill(
      {super.key,
      this.onPressed,
      this.text,
      this.size = ButtonSize.small,
      this.textColor,
      this.outlineBorder = false,
      this.disableColor,
      this.backgroundColor,
      this.maxLine,
      this.fontSize,
      this.padding,
      this.minWidth})
      : _type = _ButtonType.fill;

  const Button.outline(
      {super.key,
      this.onPressed,
      this.text,
      this.size = ButtonSize.small,
      this.textColor,
      this.disableColor,
      this.outlineBorder = false,
      this.backgroundColor,
      this.maxLine,
      this.fontSize,
      this.padding,
      this.minWidth})
      : _type = _ButtonType.outline;

  const Button.soft(
      {super.key,
      this.onPressed,
      this.text,
      this.size = ButtonSize.small,
      this.textColor,
      this.outlineBorder = false,
      this.disableColor,
      this.backgroundColor,
      this.maxLine,
      this.fontSize,
      this.padding,
      this.minWidth})
      : _type = _ButtonType.soft;

  EdgeInsetsGeometry _getPadding() {
    if (size == ButtonSize.large) {
      return const EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 12);
    } else if (size == ButtonSize.medium) {
      return const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 6);
    } else {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    }
  }

  double _getFontSize() {
    if (size == ButtonSize.large) {
      return 28;
    } else if (size == ButtonSize.medium) {
      return 28;
    } else {
      return 16;
    }
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> highlight = ValueNotifier<bool>(false);
    switch (_type) {
      case _ButtonType.fill:
        {
          return MaterialButton(
            onPressed: onPressed,
            elevation: 0,
            color: backgroundColor ?? DesignColor.primary.main,
            highlightColor: Colors.transparent,
            highlightElevation: 0,
            splashColor: DesignColor.primary.dark,
            disabledColor: disableColor ?? DesignColor.primary.main.withAlpha(140),
            padding: _getPadding(),
            minWidth: minWidth,
            textColor: textColor ?? DesignColor.white,
            shape: OutlineInputBorder(
              borderSide: BorderSide(
                color: outlineBorder ? DesignColor.primary.main : Colors.transparent,
                width: outlineBorder ? 1.0 : 0.0,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(6)),
            ),
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: Text(
                text ?? '',
                maxLines: maxLine,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize ?? _getFontSize(),
                ),
              ),
            ),
          );
        }
      case _ButtonType.outline:
        {
          return ValueListenableBuilder(
            builder: (context, value, _) {
              return MaterialButton(
                onPressed: onPressed,
                elevation: 0,
                onHighlightChanged: (data) => highlight.value = data,
                color: backgroundColor ?? DesignColor.white,
                highlightColor: Colors.transparent,
                highlightElevation: 0,
                splashColor: DesignColor.primary.dark,
                disabledColor: disableColor ?? DesignColor.white,
                padding: _getPadding(),
                minWidth: minWidth,
                textColor: value
                    ? textColor ?? DesignColor.white
                    : onPressed != null
                        ? DesignColor.primary.main
                        : DesignColor.primary.main.withAlpha(140),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: onPressed != null
                        ? DesignColor.primary.main
                        : DesignColor.primary.main.withAlpha(140),
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(6),
                  ),
                ),
                child: Padding(
                  padding: padding ?? EdgeInsets.zero,
                  child: Text(
                    text ?? '',
                    maxLines: maxLine,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize ?? _getFontSize(),
                    ),
                  ),
                ),
              );
            },
            valueListenable: highlight,
          );
        }
      default:
        {
          return ValueListenableBuilder(
            builder: (context, value, _) {
              return MaterialButton(
                onPressed: onPressed,
                elevation: 0,
                minWidth: minWidth,
                onHighlightChanged: (data) => highlight.value = data,
                color: backgroundColor ?? DesignColor.primary.light,
                highlightColor: Colors.transparent,
                highlightElevation: 0,
                splashColor: DesignColor.primary.dark,
                disabledColor: DesignColor.primary.light,
                padding: _getPadding(),
                textColor: value
                    ? textColor ?? DesignColor.white
                    : onPressed != null
                        ? DesignColor.primary.dark
                        : DesignColor.primary.dark.withAlpha(140),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(6),
                  ),
                ),
                child: Padding(
                  padding: padding ?? EdgeInsets.zero,
                  child: Text(
                    text ?? '',
                    maxLines: maxLine,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize ?? _getFontSize(),
                    ),
                  ),
                ),
              );
            },
            valueListenable: highlight,
          );
        }
    }
  }
}
