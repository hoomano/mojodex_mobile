part of design_system;

class Checkbox extends StatelessWidget {
  final bool value;
  final Function(bool?) onChanged;
  final Color? color;
  final double? size;

  const Checkbox(
    {
      required this.value, 
      required this.onChanged,
      this.color,
      this.size, Key? key
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: value 
            ? color ?? DesignColor.primary.main 
            : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: color ?? DesignColor.primary.main,
            width: 3.0,
          ),
        ),
        child: Center(
            child: value
                ? DesignIcon.check(
                    size: size,
                    color: DesignColor.white,
                  )
                : Container()),
      ),
      onTap: () {
        onChanged(!value);
      },
    );
  }
}
