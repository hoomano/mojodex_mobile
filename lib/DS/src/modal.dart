part of design_system;

class Modal extends StatefulWidget {
  final String icon;
  final String title;
  final String textContent;
  final Color? backgroundColor;
  final Color? textColor;
  final String? acceptButtonText;
  final Widget? widgetContent;
  final Function()? onAccept;
  final bool barrierDismissible;

  const Modal(
      {super.key,
      required this.icon,
      required this.title,
      required this.textContent,
      this.textColor,
      this.backgroundColor,
      this.acceptButtonText,
      this.widgetContent,
      this.onAccept,
      this.barrierDismissible = true});

  @override
  State<Modal> createState() => _ModalState();

  void show(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (ctx) => this);
  }
}

class _ModalState extends State<Modal> {
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: contentBox(context, widget.icon, widget.title, widget.textContent,
          widget.acceptButtonText, widget.backgroundColor, widget.textColor),
    );
  }

  Widget contentBox(
      BuildContext context,
      String icon,
      String title,
      String content,
      String? acceptButtonText,
      Color? backgroundColor,
      Color? textColor) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      padding: const EdgeInsets.all(Spacing.smallPadding),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: backgroundColor ??
            (themeProvider.themeMode == ThemeMode.dark
                ? DesignColor.grey.grey_7
                : DesignColor.grey.grey_1),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: themeProvider.themeMode == ThemeMode.dark
                ? DesignColor.black
                : DesignColor.grey.grey_7,
            offset: const Offset(0, 5),
            blurRadius: 5.0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("$icon\n$title",
              style: TextStyle(
                  color: themeProvider.themeMode == ThemeMode.dark
                      ? DesignColor.grey.grey_1
                      : DesignColor.grey.grey_7,
                  fontSize: TextFontSize.h4,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
          Space.verticalLarge,
          Text(content,
              style: TextStyle(
                  color: textColor ??
                      (themeProvider.themeMode == ThemeMode.dark
                          ? DesignColor.grey.grey_3
                          : DesignColor.grey.grey_5),
                  fontSize: TextFontSize.body2),
              textAlign: TextAlign.center),
          if (widget.widgetContent != null) widget.widgetContent!,
          Space.verticalLarge,
          if (widget.acceptButtonText != null)
            _processing
                ? Center(
                    child: LinearProgressIndicator(
                      color: DesignColor.primary.main,
                      backgroundColor: themeProvider.themeMode == ThemeMode.dark 
                      ? DesignColor.grey.grey_5
                      : DesignColor.grey.grey_3,
                    ),
                  )
                : Button.fill(
                    onPressed: () async {
                      setState(() {
                        _processing = true;
                      });
                      await widget.onAccept!();
                      setState(() {
                        _processing = false;
                      });
                    },
                    text: acceptButtonText,
                    textColor: themeProvider.themeMode == ThemeMode.dark
                        ? DesignColor.grey.grey_1
                        : DesignColor.grey.grey_1,
                  ),
        ],
      ),
    );
  }
}
