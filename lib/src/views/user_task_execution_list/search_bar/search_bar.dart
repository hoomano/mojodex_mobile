import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_list/search_bar/tag_filter.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../../DS/theme/themes.dart';
import '../../../models/user/user.dart';

class Debouncer {
  Debouncer({required this.milliseconds});
  final int milliseconds;
  Timer? _timer;
  void run(VoidCallback action) {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class UserTaskExecutionSearchBar extends StatefulWidget {
  final Function onSearch;
  final Function(bool) onChangeFilterVisibility;
  final FocusNode focusNode;
  final TextEditingController textEditingController;
  final Color borderColor;
  bool filtersOpened;

  UserTaskExecutionSearchBar(
      {required this.focusNode,
      required this.textEditingController,
      required this.onSearch,
      required this.onChangeFilterVisibility,
      required this.borderColor,
      required this.filtersOpened,
      Key? key})
      : super(key: key);

  @override
  State<UserTaskExecutionSearchBar> createState() =>
      _UserTaskExecutionSearchBarState();
}

class _UserTaskExecutionSearchBarState
    extends State<UserTaskExecutionSearchBar> {
  final debouncer = Debouncer(milliseconds: 500);

  bool alreadySearched = false;

  void search() {
    debouncer.run(() async {
      widget.onSearch(widget.textEditingController.text);
      alreadySearched = true;
      await User().userTaskExecutionsHistory.reloadItems(maxItemsByCall: 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(ds.Spacing.base),
                  padding: EdgeInsets.all(ds.Spacing.base),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: widget.borderColor)),
                  child: TextFormField(
                    focusNode: widget.focusNode,
                    controller: widget.textEditingController,
                    cursorColor: ds.DesignColor.primary.main,
                    style: TextStyle(
                        color: themeProvider.themeMode == ThemeMode.dark
                            ? ds.DesignColor.grey.grey_3
                            : ds.DesignColor.grey.grey_9),
                    decoration: InputDecoration(
                      prefixIcon: Container(
                        margin: EdgeInsets.all(ds.Spacing.base),
                        padding: widget.filtersOpened
                            ? const EdgeInsets.fromLTRB(
                                ds.Spacing.smallPadding,
                                ds.Spacing.base,
                                ds.Spacing.smallPadding,
                                ds.Spacing.smallPadding)
                            : const EdgeInsets.fromLTRB(
                                ds.Spacing.smallPadding,
                                ds.Spacing.smallPadding,
                                ds.Spacing.smallPadding,
                                ds.Spacing.base),
                        child: ds.DesignIcon.searchMagnifyingGlass(
                            size: 1,
                            color: themeProvider.themeMode == ThemeMode.dark
                                ? ds.DesignColor.grey.grey_5
                                : ds.DesignColor.grey.grey_3),
                      ),
                      prefix: ds.Space.horizontalSmall,
                      border: InputBorder.none,
                      hintText: "Search",
                    ),
                    onChanged: (value) async {
                      // Call your API to fetch tasks when the user types a query of at least 3 characters
                      search();
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: ds.Spacing.smallPadding),
                child: InkWell(
                  child: ds.DesignIcon.filter(
                      size: ds.TextFontSize.h3,
                      color: User()
                              .userTaskExecutionsHistory
                              .userTaskExecutionsAreFilteredByUserTaskPks
                              .isNotEmpty
                          ? ds.DesignColor.primary.main
                          : ds.DesignColor.grey.grey_3),
                  onTap: () {
                    setState(() {
                      widget.filtersOpened = !widget.filtersOpened;
                    });
                    widget.onChangeFilterVisibility(widget.filtersOpened);
                  },
                ),
              )
            ],
          ),
        ),
        Visibility(
          visible: widget.filtersOpened,
          child: Flexible(
            child: Container(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: User()
                    .userTasksList
                    .where((userTask) => userTask.pk != null)
                    .map((userTask) => UserTaskFilter(
                          userTask: userTask,
                          selected: User()
                              .userTaskExecutionsHistory
                              .userTaskExecutionsAreFilteredByUserTaskPks
                              .contains(userTask.pk!),
                          onTap: (selected) {
                            selected
                                ? User()
                                    .userTaskExecutionsHistory
                                    .userTaskExecutionsAreFilteredByUserTaskPks
                                    .add(userTask.pk!)
                                : User()
                                    .userTaskExecutionsHistory
                                    .userTaskExecutionsAreFilteredByUserTaskPks
                                    .remove(userTask.pk!);
                            setState(() {});
                            search();
                          },
                        ))
                    .toList(),
              ),
            ),
          ),
        )
      ],
    );
  }
}
