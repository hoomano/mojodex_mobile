part of design_system;

class Radios extends StatelessWidget {
  final String group;
  final List<String> values;
  final Function(String?) onChange;

  const Radios(
      {super.key,
      required this.group,
      required this.values,
      required this.onChange});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: DesignColor.primary.main,
      strokeWidth: 2,
      dashPattern: const [10],
      padding: const EdgeInsets.all(8.0),
      radius: const Radius.circular(5.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ...List<Widget>.generate(values.length, (index) {
            String item = values[index];
            return Row(mainAxisSize: MainAxisSize.min, children: [
              Radio(
                activeColor: DesignColor.primary.main,
                value: item,
                groupValue: group,
                onChanged: onChange,
              ),
              Text(item)
            ]);
          })
        ],
      ),
    );
  }
}
