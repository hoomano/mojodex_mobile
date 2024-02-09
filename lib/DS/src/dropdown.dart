part of design_system;

class Dropdown extends StatelessWidget {
  final List<String> items;
  final String? selectedValue;
  final double width;
  final String? headingText;
  final double? maxHeight;
  final Function(String?) onChange;

  const Dropdown(
      {super.key,
      this.items = const [],
      this.width = 164,
      this.maxHeight,
      required this.selectedValue,
      required this.onChange,
      this.headingText});

  @override
  Widget build(BuildContext context) {
    return DropdownButton2(
      isExpanded: true,
      customButton: Container(
        width: 164,
        padding: const EdgeInsets.only(left: 24, right: 24, top: 6, bottom: 8),
        decoration: BoxDecoration(
            border: Border.all(color: DesignColor.grey.grey_3),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        child: Text(headingText ?? '',
            style: TextStyle(color: DesignColor.grey.grey_3, fontSize: 14)),
      ),
      underline: const SizedBox.shrink(),
      items: items
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Builder(builder: (context) {
                  ValueNotifier<Color> textColor =
                      ValueNotifier(DesignColor.grey.grey_5);
                  late Offset initialPosition;
                  return Listener(
                    onPointerHover: (data) {
                      initialPosition = data.position;
                      if (item != selectedValue) {
                        textColor.value = DesignColor.white;
                      }
                    },
                    onPointerUp: (data) {
                      textColor.value = DesignColor.grey.grey_5;
                    },
                    onPointerMove: (data) {
                      if ((data.position.dx - initialPosition.dx).abs() > 43) {
                        textColor.value = DesignColor.grey.grey_5;
                      }
                      if ((data.position.dy - initialPosition.dy).abs() > 43) {
                        textColor.value = DesignColor.grey.grey_5;
                      }
                    },
                    child: SizedBox.expand(
                      child: ValueListenableBuilder<Color>(
                          valueListenable: textColor,
                          builder: (context, color, _) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: color,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }),
                    ),
                  );
                }),
              ))
          .toList(),
      value: selectedValue,
      onChanged: onChange,
      buttonStyleData: ButtonStyleData(
          height: 50,
          width: width,
          padding: const EdgeInsets.only(left: 14, right: 14),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(color: const Color(0xff879BB7)),
            color: DesignColor.white,
          )),
      iconStyleData: const IconStyleData(icon: SizedBox.shrink()),
      dropdownStyleData: DropdownStyleData(
          maxHeight: maxHeight,
          offset: const Offset(0, 34),
          width: width,
          padding: null,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: Border.all(color: DesignColor.grey.grey_3)),
          elevation: 8),
      menuItemStyleData: MenuItemStyleData(
          selectedMenuItemBuilder: (context, child) {
            return Container(color: DesignColor.primary.light, child: child);
          },
          overlayColor: MaterialStatePropertyAll(DesignColor.primary.main),
          height: 40,
          padding: const EdgeInsets.only(left: 14, right: 14)),
    );
  }
}
