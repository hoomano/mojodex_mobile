part of design_system;

enum _TabsType { defaultFill, outline }

enum TabsSize { defaultSize, lg }

class Tabs extends StatelessWidget {
  final String selectedItem;
  final List<String> items;
  final Function(String) onChange;
  final _TabsType _type;
  final TabsSize size;

  const Tabs.outline(
      {super.key,
      required this.onChange,
      required this.selectedItem,
      required this.items,
      this.size = TabsSize.defaultSize})
      : _type = _TabsType.outline;

  const Tabs(
      {super.key,
      required this.onChange,
      required this.selectedItem,
      required this.items,
      this.size = TabsSize.defaultSize})
      : _type = _TabsType.defaultFill;

  bool get _isDefault => _type == _TabsType.defaultFill;

  bool get _isSizeDefault => size == TabsSize.defaultSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
          color: _isDefault ? DesignColor.primary.main : DesignColor.white,
          border: _isDefault
              ? null
              : Border.all(color: DesignColor.primary.main, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(8.0))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List<Widget>.generate(items.length, (index) {
            String item = items[index];
            return AbsorbPointer(
              absorbing: item == selectedItem,
              child: InkWell(
                onTap: () => onChange(item),
                onLongPress: () => onChange(item),
                child: Container(
                  decoration: BoxDecoration(
                      color: item == selectedItem
                          ? DesignColor.primary.dark
                          : Colors.transparent,
                      border: index < items.length - 1 || _isDefault
                          ? Border(
                              right:
                                  BorderSide(color: DesignColor.primary.main))
                          : null),
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    child: Container(
                      height: _isSizeDefault ? 48 : 60,
                      padding: _isSizeDefault
                          ? const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10)
                          : const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                      child: Center(
                        child: Text(item,
                            style: TextStyle(
                                color: item == selectedItem || _isDefault
                                    ? DesignColor.white
                                    : DesignColor.primary.main)),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
