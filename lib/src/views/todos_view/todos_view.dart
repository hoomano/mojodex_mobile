import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/views/todos_view/empty_todo_list.dart';
import 'package:mojodex_mobile/src/views/todos_view/todos_list.dart';
import 'package:mojodex_mobile/src/views/widgets/common_scaffold.dart';
import 'package:provider/provider.dart';

import '../../../DS/design_system.dart' as ds;
import '../../../DS/theme/themes.dart';
import '../../models/todos/todo-list.dart';
import '../../models/todos/todos.dart';
import '../../models/user/user.dart';
import '../drawer/app_drawer.dart';
import '../skeletons/skeleton_list.dart';

class TodosListView extends StatefulWidget {
  static String routeName = "todos";
  final Logger logger = Logger('TodosView');

  @override
  State<TodosListView> createState() => _TodosListViewState();
}

class _TodosListViewState extends State<TodosListView> {
  double lastScrollOffset = 0;

  bool processingRequest = false;
  ScrollController controller = ScrollController();

  Future<void> loadMore() async {
    if (processingRequest) return;
    processingRequest = true;
    await User()
        .todoList
        .loadMoreItems(offset: User().todoList.currentDisplayedListOffset);
    processingRequest = false;
    if (mounted) setState(() {});
  }

  void onScrollChange() {
    lastScrollOffset = controller.offset;
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(onScrollChange);
  }

  @override
  void dispose() {
    controller.removeListener(onScrollChange);
    super.dispose();
  }

  void setStateIfMounted() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Consumer<TodoList>(builder: (context, todoList, child) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!todoList.loading) {
          todoList.markAllTodosAsRead();
        }
      });
      List<Todo> todos = todoList.displayedTodos;

      return MojodexScaffold(
        appBarTitle: "Todos",
        safeAreaOverflow: true,
        drawer: AppDrawer(),
        body: (todos.isNotEmpty && !todoList.loading)
            ? LazyLoadScrollView(
                onEndOfPage: () =>
                    loadMore().then((value) => setStateIfMounted()),
                scrollOffset: 300,
                child: SingleChildScrollView(
                  controller: controller,
                  child: TodosList(
                      todos: todos,
                      navigateToUserTaskExecutionViewOnTap: true,
                      onGetEmpty: () => setStateIfMounted()),
                ),
              )
            : !todoList.loading
                ? EmptyTodoList()
                : SkeletonList(),
        bottomBarWidget:
            Consumer<TodoList>(builder: (context, todoList, child) {
          return Visibility(
              visible: todoList.refreshing,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: ds.Spacing.smallPadding,
                    vertical: ds.Spacing.mediumPadding),
                child: LinearProgressIndicator(
                  color: ds.DesignColor.primary.main,
                  backgroundColor: themeProvider.themeMode == ThemeMode.dark
                      ? ds.DesignColor.grey.grey_7
                      : ds.DesignColor.grey.grey_3,
                ),
              ));
        }),
      );
    });
  }
}
