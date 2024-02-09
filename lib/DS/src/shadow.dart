part of design_system;

enum _ShadowType { small, regular, larger }

class Shadow extends StatelessWidget {
  final Widget? child;

  final _ShadowType _type;

  const Shadow.small({super.key, this.child}) : _type = _ShadowType.small;

  const Shadow.regular({super.key, this.child}) : _type = _ShadowType.regular;

  const Shadow.larger({super.key, this.child}) : _type = _ShadowType.larger;

  @override
  Widget build(BuildContext context) {
    switch (_type) {
      case _ShadowType.small:
        {
          return Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                  offset: const Offset(0, 1),
                  blurRadius: 4.0,
                  color: Colors.black.withOpacity(0.1))
            ]),
            child: child,
          );
        }
      case _ShadowType.regular:
        {
          return Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                  offset: const Offset(0, 4),
                  blurRadius: 10.0,
                  color: Colors.black.withOpacity(0.12))
            ]),
            child: child,
          );
        }
      default:
        {
          return Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                  offset: const Offset(0, 8),
                  blurRadius: 35.0,
                  color: Colors.black.withOpacity(0.16))
            ]),
            child: child,
          );
        }
    }
  }
}
