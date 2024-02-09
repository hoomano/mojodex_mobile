part of design_system;

class DesignIcon {
  DesignIcon._();

  static Widget _universalIcons(String asset,
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return Transform.rotate(
      angle: rotationAngle, // Specify the rotation angle in radians
      child: Image.asset(
        "lib/DS/icons/$asset",
        color: color,
        width: size,
        fit: fit,
        height: size,
      ),
    );
  }

  static Widget addPlus(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Add_Plus.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget arrowDownLG(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Arrow_Down_LG.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget arrowDownMD(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Arrow_Down_MD.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget arrowLeftLG(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Arrow_Left_LG.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget arrowLeftMD(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Arrow_Left_MD.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget arrowRightLG(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Arrow_Right_LG.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget arrowRightMD(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Arrow_Right_MD.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget arrowUpLG(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Arrow_Up_LG.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget arrowUpMD(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Arrow_Up_MD.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget bell(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Bell.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget bookmark(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Bookmark.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget camera(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Camera.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget caretDownMD(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Caret_Down_MD.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget caretUpMD(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Caret_Up_MD.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget chat(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Chat.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget chatCircle(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Chat_Circle.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget chatConversation(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Chat_Conversation.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget check(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Check.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget checkBig(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Check_Big.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget chevronDown(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Chevron_Down.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget chevronLeft(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Chevron_Left.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget chevronLeftMD(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Chevron_Left_MD.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget chevronRight(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Chevron_Right.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget chevronRightMD(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Chevron_Right_MD.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget chevronUp(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Chevron_Up.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget circleCheck(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Circle_Check.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget circleWarning(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Circle_Warning.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget closeLG(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Close_LG.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget closeMD(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Close_MD.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget closeSM(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Close_SM.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget cloud(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Cloud.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget copy(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Copy.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget creditCard01(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Credit_Card_01.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget crop(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Crop.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget download(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Download.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget editPencil01(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Edit_Pencil_01.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget exit(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Exit.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget externalLink(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("External_Link.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget filter(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Filter.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget flag(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Flag.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget folder(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Folder.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget gift(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Gift.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget globe(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Globe.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget hamburgerLG(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Hamburger_LG.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget hamburgerMD(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Hamburger_MD.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget heart01(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Heart_01.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget heart02(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Heart_02.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget image01(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Image_01.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget info(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Info.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget interface(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Interface.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget label(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Label.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget laptop(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Laptop.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget link(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Link.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget linkHorizontal(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Link_Horizontal.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget lock(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Lock.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget magnifyingGlassMinus(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Magnifying_Glass_Minus.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget magnifyingGlassPlus(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Magnifying_Glass_Plus.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget mail(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Mail.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget map(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Map.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget mapPin(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Map_Pin.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget moreGridBig(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("More_Grid_Big.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget moreVertical(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("More_Vertical.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget navigation(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Navigation.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget paperPlane(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Paper_Plane.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget paperclipAttechmentTilt(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Paperclip_Attechment_Tilt.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget phone(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Phone.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget play(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Play.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget playCircle(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Play_Circle.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget searchMagnifyingGlass(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Search_Magnifying_Glass.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget settings(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Settings.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget shareAndroid(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Share_Android.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget shoppingCart01(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Shopping_Cart_01.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget show(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Show.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget slider01(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Slider_01.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget slider03(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Slider_03.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget star(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Star.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget stopSign(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Stop_Sign.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget suitcase(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Suitcase.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget tag(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Tag.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget trashEmpty(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Trash_Empty.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget triangleWarning(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Triangle_Warning.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget unfoldMore(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("Unfold_More.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget user01(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("User_01.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }

  static Widget user02(
      {double? size,
      Color color = Colors.white,
      BoxFit? fit,
      double rotationAngle = 0.0}) {
    return _universalIcons("User_02.png",
        size: size, color: color, fit: fit, rotationAngle: rotationAngle);
  }
}
