part of design_system;

class Spinner extends StatelessWidget {
  final Color color;
  final double? size;
  final double strokeWidth;

  const Spinner(
      {super.key, this.color = Colors.black, this.size, this.strokeWidth = 8});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
  }
}
