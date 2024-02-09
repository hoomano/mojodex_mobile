part of design_system;

class Pagination extends StatelessWidget {
  final int selectedIndex;
  final int itemsNumber;
  final Function(int) onChange;

  Pagination(
      {super.key,
      required this.selectedIndex,
      required this.itemsNumber,
      required this.onChange})
      : assert(selectedIndex <= itemsNumber && selectedIndex > 0);

  @override
  Widget build(BuildContext context) {
    final labelsProvider = Provider.of<SystemLanguage>(context);
    return Row(
      children: [
        AbsorbPointer(
          absorbing: selectedIndex == 1,
          child: InkWell(
            onTap: () => onChange(selectedIndex - 1),
            onLongPress: () => onChange(selectedIndex - 1),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: const BoxDecoration(
                  color: DesignColor.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8))),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(labelsProvider.getText(key: "previousButton"),
                      style: TextStyle(color: DesignColor.grey.grey_1))),
            ),
          ),
        ),
        ...List<Widget>.generate(itemsNumber, (index) {
          int page = index + 1;
          return AbsorbPointer(
            absorbing: page == selectedIndex,
            child: InkWell(
              onTap: () => onChange(page),
              onLongPress: () => onChange(page),
              child: Container(
                width: 41,
                height: 40,
                color: page == selectedIndex
                    ? DesignColor.primary.main
                    : DesignColor.white,
                margin: EdgeInsets.only(
                    left: 1.0, right: page == itemsNumber ? 1.0 : 0.0),
                child: Center(
                  child: Text(page.toString(),
                      style: TextStyle(
                          color: page == selectedIndex
                              ? DesignColor.white
                              : DesignColor.primary.main)),
                ),
              ),
            ),
          );
        }),
        AbsorbPointer(
          absorbing: selectedIndex == itemsNumber,
          child: InkWell(
            onTap: () => onChange(selectedIndex + 1),
            onLongPress: () => onChange(selectedIndex + 1),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: const BoxDecoration(
                  color: DesignColor.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8))),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(labelsProvider.getText(key: "nextButton"),
                      style: TextStyle(color: DesignColor.primary.main))),
            ),
          ),
        )
      ],
    );
  }
}
