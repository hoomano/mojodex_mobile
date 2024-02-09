import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/tasks/user_task_executions_history.dart';
import 'package:mojodex_mobile/src/views/new_user_task_execution/new_user_task_execution.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_list/search_bar/search_bar.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_list/user_task_execution_tile.dart';
import 'package:mojodex_mobile/src/views/widgets/common_scaffold.dart';
import 'package:provider/provider.dart';

import '../../../DS/design_system.dart' as ds;
import '../../../DS/theme/themes.dart';
import '../../models/language/system_language.dart';
import '../../models/tasks/user_task_execution.dart';
import '../../models/user/user.dart';
import '../drawer/app_drawer.dart';
import '../skeletons/skeleton_list.dart';

class UserTaskExecutionsListView extends StatefulWidget {
  static String routeName = "tasks";
  final Logger logger = Logger('UserTaskExecutionListView');

  @override
  State<StatefulWidget> createState() => UserTaskExecutionsListViewState();
}

class UserTaskExecutionsListViewState
    extends State<UserTaskExecutionsListView> {
  FocusNode focusNode = FocusNode();

  double lastScrollOffset = 0;

  final TextEditingController searchTextEditingController =
      TextEditingController();

  bool loadingMore = false;
  ScrollController controller = ScrollController();

  Future<void> loadMore() async {
    if (loadingMore) return;
    loadingMore = true;
    await User().userTaskExecutionsHistory.loadMoreItems(
        maxItemsByCall: 10, offset: User().userTaskExecutionsHistory.length);
    loadingMore = false;
    if (mounted) {
      setState(() {});
    }
  }

  late double _searchBarHeight;
  double _defaultSearchBarHeight = 60;
  double _searchBarHeightWithFilter = 120;
  bool _filtersOpened = false;

  void onScrollChange() {
    final currentDirection = controller.position.userScrollDirection;

    if (currentDirection == ScrollDirection.reverse) {
      if (lastScrollOffset != 0 && _searchBarHeight != 0) {
        // Show the search bar only when the scroll is upward
        setState(() => _searchBarHeight = 0);
      }

      // Hide the keyboard
      focusNode.unfocus();
    } else if (currentDirection == ScrollDirection.forward &&
        _searchBarHeight == 0) {
      // Hide the search bar when scrolling down
      setState(() => _searchBarHeight = !_filtersOpened
          ? _defaultSearchBarHeight
          : _searchBarHeightWithFilter);
    }

    lastScrollOffset = controller.offset;
  }

  @override
  void initState() {
    if (User()
        .userTaskExecutionsHistory
        .userTaskExecutionsAreFilteredByUserTaskPks
        .isNotEmpty) {
      _searchBarHeight = _searchBarHeightWithFilter;
      _filtersOpened = true;
    } else {
      if (User().userTaskExecutionsHistory.userTaskExecutionsAreFilteredBy ==
          null) {
        _searchBarHeight = 0;
      } else {
        _searchBarHeight = _defaultSearchBarHeight;
      }
    }
    if (_searchBarHeight != 0) {
      searchTextEditingController.text =
          User().userTaskExecutionsHistory.userTaskExecutionsAreFilteredBy!;
    }

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
    final labelsProvider = Provider.of<SystemLanguage>(context);

    return MojodexScaffold(
      safeAreaOverflow: true,
      drawer: AppDrawer(),
      appBarTitle:
          labelsProvider.getText(key: "userTaskExecutionList.appBarTitle"),
      appBarAction: Consumer<UserTaskExecutionsHistory>(
          builder: (context, userTaskExecutionsHistory, child) {
        return userTaskExecutionsHistory.loading
            ? Container()
            : IconButton(
                icon: ds.DesignIcon.addPlus(size: 30),
                onPressed: () {
                  context.pushNamed(NewUserTaskExecution.routeName);
                },
              );
      }),
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _searchBarHeight,
            curve: Curves.linear,
            child: UserTaskExecutionSearchBar(
              filtersOpened: _filtersOpened,
              borderColor: _searchBarHeight == 0
                  ? Colors.transparent
                  : themeProvider.themeMode == ThemeMode.dark
                      ? ds.DesignColor.grey.grey_7
                      : ds.DesignColor.grey.grey_1,
              focusNode: focusNode,
              textEditingController: searchTextEditingController,
              onSearch: (value) {
                if (value.length <= 2) {
                  User()
                      .userTaskExecutionsHistory
                      .userTaskExecutionsAreFilteredBy = null;
                } else {
                  User()
                      .userTaskExecutionsHistory
                      .userTaskExecutionsAreFilteredBy = value;
                }
              },
              onChangeFilterVisibility: (filterIsVisible) {
                setState(() {
                  _filtersOpened = filterIsVisible;
                  _searchBarHeight = filterIsVisible
                      ? _searchBarHeightWithFilter
                      : _defaultSearchBarHeight;
                });
              },
            ),
          ),
          Consumer<UserTaskExecutionsHistory>(
              builder: (context, userTaskExecutionsHistory, child) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!userTaskExecutionsHistory.loading &&
                  userTaskExecutionsHistory.isEmpty &&
                  userTaskExecutionsHistory.initialLoadDone.value &&
                  _searchBarHeight == 0 &&
                  GoRouter.of(context).routeInformationProvider.value.uri ==
                      Uri(path: "/${UserTaskExecutionsListView.routeName}")) {
                context.pushReplacementNamed(NewUserTaskExecution.routeName);
              }
            });
            return Expanded(
              child: userTaskExecutionsHistory.isNotEmpty
                  ? LazyLoadScrollView(
                      onEndOfPage: () =>
                          loadMore().then((value) => setStateIfMounted()),
                      scrollOffset: 300,
                      child: SingleChildScrollView(
                        controller: controller,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List<Widget>.generate(
                              userTaskExecutionsHistory.length, (index) {
                            UserTaskExecution userTaskExecution =
                                userTaskExecutionsHistory[index];
                            return ChangeNotifierProvider<
                                UserTaskExecution>.value(
                              value: userTaskExecution,
                              child: UserTaskExecutionTile(),
                            );
                          }),
                        ),
                      ),
                    )
                  : userTaskExecutionsHistory.loading ||
                          !userTaskExecutionsHistory.initialLoadDone.value
                      ? SkeletonList()
                      : Padding(
                          padding:
                              const EdgeInsets.all(ds.Spacing.largePadding),
                          child: Center(
                            child: Text(
                                "🤔\nIt seems there is no such thing in your task history...",
                                style: TextStyle(
                                    fontSize: ds.TextFontSize.h4,
                                    color: themeProvider.themeMode ==
                                            ThemeMode.dark
                                        ? ds.DesignColor.grey.grey_1
                                        : ds.DesignColor.grey.grey_9),
                                textAlign: TextAlign.start),
                          ),
                        ),
            );
          }),
          if (loadingMore)
            Padding(
              padding: const EdgeInsets.all(ds.Spacing.largePadding),
              child: Center(
                  child: CircularProgressIndicator(
                      color: ds.DesignColor.grey.grey_3, strokeWidth: 2)),
            )
        ],
      ),
      bottomBarWidget: Consumer<UserTaskExecutionsHistory>(
          builder: (context, userTaskExecutionsHistory, child) {
        return Visibility(
            visible: userTaskExecutionsHistory.refreshing,
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
  }
}
