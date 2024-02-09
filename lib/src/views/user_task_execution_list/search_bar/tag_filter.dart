import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../../DS/theme/themes.dart';
import '../../../models/tasks/user_task.dart';

class UserTaskFilter extends StatefulWidget {
  final UserTask userTask;
  final Function onTap;
  bool selected;

  UserTaskFilter(
      {required this.userTask,
      required this.onTap,
      required this.selected,
      Key? key})
      : super(key: key);

  @override
  State<UserTaskFilter> createState() => _UserTaskFilterState();
}

class _UserTaskFilterState extends State<UserTaskFilter> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return InkWell(
      onTap: () {
        setState(() {
          widget.selected = !widget.selected;
        });
        widget.onTap(widget.selected);
      },
      child: Container(
        margin: EdgeInsets.all(ds.Spacing.base),
        padding: EdgeInsets.symmetric(
          horizontal: ds.Spacing.smallPadding,
        ),
        decoration: BoxDecoration(
            color: widget.selected ? ds.DesignColor.primary.main : null,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: ds.DesignColor.primary.main,
            )),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ds.Spacing.smallPadding,
            ),
            child: Row(
              children: [
                Text(
                  "${widget.userTask.task.icon}",
                  style: TextStyle(
                    fontSize: ds.TextFontSize.body2,
                    color: widget.selected
                        ? ds.DesignColor.white
                        : ds.DesignColor.primary.main,
                  ),
                ),
                Text(
                  "${widget.userTask.task.name}",
                  style: TextStyle(
                    fontSize: ds.TextFontSize.body2,
                    color: widget.selected
                        ? ds.DesignColor.white
                        : ds.DesignColor.primary.main,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
