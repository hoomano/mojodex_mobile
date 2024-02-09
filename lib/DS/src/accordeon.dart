part of design_system;

class Accordeon extends StatelessWidget {
  const Accordeon({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        color: Colors.white,
        child: const ExpansionTile(
          backgroundColor: Colors.white,
          childrenPadding: EdgeInsets.all(16),
          trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.black),
          title:
              Text("Accordion Item #1", style: TextStyle(color: Colors.black)),
          children: [
            Text(
                "This is the first item's accordion body. It is hidden by default, until the collapse plugin adds the appropriate classes that we use to style each element. These classes control the overall appearance, as well as the showing and hiding via CSS transitions.",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
