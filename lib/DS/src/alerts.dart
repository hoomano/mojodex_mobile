part of design_system;

class Alerts {
  Alerts.primary(BuildContext context, Widget? content,
      {Widget? leading, Widget? subtitle, bool hasLeading = true}) {
    SnackBar snackBar = SnackBar(
      elevation: 0,
      content: ListTile(
        leading: hasLeading
            ? leading ?? DesignIcon.bell(color: DesignColor.primary.dark)
            : null,
        textColor: DesignColor.primary.dark,
        title: content,
        subtitle: subtitle,
      ),
      backgroundColor: DesignColor.primary.light,
      behavior: SnackBarBehavior.floating,
      closeIconColor: DesignColor.primary.dark,
      showCloseIcon: true,
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Alerts.success(BuildContext context, Widget? content,
      {Widget? leading, Widget? subtitle, bool hasLeading = true}) {
    SnackBar snackBar = SnackBar(
      elevation: 0,
      content: ListTile(
        leading: hasLeading
            ? leading ?? DesignIcon.check(color: DesignColor.status.success)
            : null,
        textColor: DesignColor.status.success,
        title: content,
        subtitle: subtitle,
      ),
      backgroundColor: DesignColor.status.successSecondary,
      behavior: SnackBarBehavior.floating,
      closeIconColor: DesignColor.status.success,
      showCloseIcon: true,
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
          side: BorderSide(color: DesignColor.status.success.withAlpha(50)),
          borderRadius: BorderRadius.circular(6)),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Alerts.danger(BuildContext context, Widget? content,
      {Widget? leading, Widget? subtitle, bool hasLeading = true}) {
    SnackBar snackBar = SnackBar(
      elevation: 0,
      content: ListTile(
        leading: hasLeading
            ? leading ??
                DesignIcon.triangleWarning(color: DesignColor.status.error)
            : null,
        textColor: DesignColor.status.error,
        title: content,
        subtitle: subtitle,
      ),
      backgroundColor: DesignColor.status.error.withAlpha(50),
      behavior: SnackBarBehavior.floating,
      closeIconColor: DesignColor.status.error,
      showCloseIcon: true,
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
          side: BorderSide(color: DesignColor.status.error.withAlpha(50)),
          borderRadius: BorderRadius.circular(6)),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Alerts.light(BuildContext context, Widget? content,
      {Widget? leading, Widget? subtitle, bool hasLeading = true}) {
    SnackBar snackBar = SnackBar(
      elevation: 0,
      content: ListTile(
        leading: hasLeading
            ? leading ?? DesignIcon.info(color: DesignColor.black)
            : null,
        textColor: DesignColor.black,
        title: content,
        subtitle: subtitle,
      ),
      backgroundColor: DesignColor.grey.grey_1,
      behavior: SnackBarBehavior.floating,
      closeIconColor: DesignColor.black,
      showCloseIcon: true,
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
          side: BorderSide(color: DesignColor.grey.grey_3),
          borderRadius: BorderRadius.circular(6)),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
