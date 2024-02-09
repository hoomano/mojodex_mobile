import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/views/todos_view/todo_tile.dart';
import 'package:provider/provider.dart';

import '../../../DS/design_system.dart' as ds;
import '../../../DS/theme/themes.dart';
import '../../models/todos/todos.dart';

class TodosList extends StatefulWidget {
  final String todayString = "Today";
  final String tomorrowString = "Tomorrow";
  final List<Todo> todos;
  final bool navigateToUserTaskExecutionViewOnTap;
  final bool showCompleted;
  final Function? onGetEmpty;
  TodosList(
      {required this.todos,
      this.navigateToUserTaskExecutionViewOnTap = false,
      this.showCompleted = false,
      this.onGetEmpty,
      Key? key})
      : super(key: key);

  @override
  State<TodosList> createState() => _TodosListState();
}

class _TodosListState extends State<TodosList> {
  String formatDateString(String date) {
    var now = DateTime.now();
    var today = DateTime(now.year, now.month, now.day);
    var tomorrow = today.add(Duration(days: 1));
    var parsedDate = DateTime.tryParse(date)?.toLocal();

    if (parsedDate == null) {
      return date;
    }

    var isToday = parsedDate.difference(today).inDays == 0;
    if (isToday) {
      return widget.todayString;
    }

    var isTomorrow = parsedDate.difference(tomorrow).inDays == 0;
    if (isTomorrow) {
      return widget.tomorrowString;
    }

    if (parsedDate.year == today.year) {
      // number of day + 3 first letters of month
      return DateFormat('d MMM').format(parsedDate);
    } else {
      // number of day + 3 first letters of month + year
      return DateFormat('d MMM y').format(parsedDate);
    }
  }

  // Used to prevent taping anywhere during loading
  bool processing = false;

  late Map<String, List<Todo>> groupedTodos;

  bool _displayTodo(Todo todo) {
    bool isTodoVisible = true;
    if (todo.completed) {
      if (widget.showCompleted) {
        isTodoVisible = true;
      } else {
        isTodoVisible = todo.visible;
      }
    } else {
      isTodoVisible = todo.visible;
    }
    return isTodoVisible;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    List<Todo> todosToDisplay =
        widget.todos.where((element) => _displayTodo(element)).toList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (todosToDisplay.isEmpty && widget.onGetEmpty != null) {
        widget.onGetEmpty!();
      }
    });

    groupedTodos = groupBy<Todo, String>(
      todosToDisplay,
      (todo) => DateFormat('yyyy-MM-dd').format(todo.scheduledDate),
    );

    return AbsorbPointer(
      absorbing: processing,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groupedTodos.entries.map<Widget>((entry) {
          String dateString = formatDateString(entry.key);

          List<Widget> todoTiles = entry.value
              .map<Widget>((todo) => ChangeNotifierProvider<Todo>.value(
                    value: todo,
                    child: TodoTile(
                        onVisibilityChanged: () {
                          setState(() {});
                        },
                        showCompleted: widget.showCompleted,
                        navigateToUserTaskExecutionViewOnTap:
                            widget.navigateToUserTaskExecutionViewOnTap,
                        onLoading: () {
                          setState(() {
                            processing = true;
                          });
                        },
                        onLoadingOver: () {
                          setState(() {
                            processing = false;
                          });
                        }),
                  ))
              .toList();

          bool isFirstGroup = groupedTodos.entries.first.key == entry.key;

          Color groupTitleColor;
          if (themeProvider.themeMode == ThemeMode.dark) {
            groupTitleColor = dateString == widget.todayString
                ? ds.DesignColor.grey.grey_1
                : ds.DesignColor.grey.grey_3;
          } else {
            groupTitleColor = dateString == widget.todayString
                ? ds.DesignColor.grey.grey_9
                : ds.DesignColor.grey.grey_3;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // if it is not first item, Display a divider
              isFirstGroup ? ds.Space.verticalLarge : const Divider(),
              Padding(
                padding: const EdgeInsets.all(ds.Spacing.smallPadding),
                child: Text(
                  dateString,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: dateString == widget.todayString
                          ? ds.TextFontSize.h3
                          : ds.TextFontSize.h5,
                      fontWeight: dateString == widget.todayString
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: groupTitleColor),
                ),
              ),
              ...todoTiles,
            ],
          );
        }).toList(),
      ),
    );
  }
}
