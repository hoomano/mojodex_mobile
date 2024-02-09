import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/microphone.dart';
import 'package:mojodex_mobile/src/models/tasks/user_task.dart';
import 'package:mojodex_mobile/src/models/user/user.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_view/todos_view/task_execution_todos_list.dart';
import 'package:mojodex_mobile/src/views/widgets/common_scaffold.dart';
import 'package:provider/provider.dart';

import '../../../DS/design_system.dart' as ds;
import '../../models/session/messages/user_message.dart';
import '../../models/session/session.dart';
import '../../models/tasks/user_task_execution.dart';
import 'chat_view/chat_view.dart';
import 'deleted_user_task_execution.dart';
import 'result_view/result_view.dart';

class UserTaskExecutionView extends StatefulWidget {
  static const chatTabName = 'Chat';
  static const resultTabName = 'Result';
  //static const actionsTabName = 'Actions';
  static const todosTabName = 'Todos';

  final UserTaskExecution userTaskExecution;
  final String initialTab;
  final UserMessage? firstMessageToSend;

  // userTaskExecution should be refreshed onlyif it's not a new one
  final bool refreshUserTaskExecution;

  const UserTaskExecutionView(
      {super.key,
      required this.userTaskExecution,
      this.initialTab = resultTabName,
      this.firstMessageToSend,
      this.refreshUserTaskExecution = true});

  @override
  State<UserTaskExecutionView> createState() => _UserTaskExecutionViewState();
}

class _UserTaskExecutionViewState extends State<UserTaskExecutionView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool get resultTabEnabled =>
      widget.userTaskExecution.producedText != null ||
      widget.userTaskExecution.session.mojoDrafting;

  bool get todosTabEnabled => widget.userTaskExecution.nTodos > 0;

  ScrollPhysics? get swipePhysics {
    if (_tabController.index == 0 && !resultTabEnabled) {
      return const NeverScrollableScrollPhysics();
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    // if session is not already connected, connect to it
    widget.userTaskExecution.session.connectToSession();

    // refresh userTaskExecution
    if (widget.refreshUserTaskExecution) {
      widget.userTaskExecution.refresh();
    }

    _tabController = TabController(vsync: this, length: 3);

    _tabController.addListener(() {
      if (_tabController.index != 0 && !resultTabEnabled) {
        setState(() {
          _tabController.index = 0;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialTab == UserTaskExecutionView.chatTabName) {
        _tabController.animateTo(0);
      } else if (widget.initialTab == UserTaskExecutionView.resultTabName) {
        _tabController.animateTo(1);
      } else if (widget.initialTab == UserTaskExecutionView.todosTabName) {
        _tabController.animateTo(2);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onDraftGenerated() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabController.animateTo(1);
      setState(() {
        // to change tabs colors because now resultTabEnabled = true.
      });
    });
    widget.userTaskExecution.session.draftStarted.add(
        false); // consume the event to avoid being always redirected to result tab
  }

  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _processing,
      child: ChangeNotifierProvider<UserTaskExecution>.value(
        value: widget.userTaskExecution,
        child: Consumer<UserTaskExecution>(
            builder: (context, userTaskExecution, child) {
          if (userTaskExecution.deletedByUser) {
            return DeletedUserTaskExecution();
          }
          return StreamBuilder<String>(
              stream: userTaskExecution.session.userTaskExecutionTitleStream,
              builder: (context, snapshot) {
                String appBarTitle;
                if (snapshot.hasData) {
                  appBarTitle = snapshot.data!;
                } else {
                  if (userTaskExecution.title != null) {
                    appBarTitle = userTaskExecution.title!;
                  } else {
                    UserTask userTask = User()
                        .userTasksList
                        .getParticularItemSync(userTaskExecution.userTaskPk)!;
                    appBarTitle = "${userTask.task.icon} ${userTask.task.name}";
                  }
                }
                return MojodexScaffold(
                  appBarTitle: appBarTitle,
                  safeAreaOverflow: false,
                  appBarBottom: TabBar(
                    labelColor: ds.DesignColor.white,
                    unselectedLabelColor:
                        (_tabController.index == 0 && !resultTabEnabled)
                            ? ds.DesignColor.grey.grey_5
                            : ds.DesignColor.grey.grey_1,
                    controller: _tabController,
                    tabs: [
                      const Tab(text: UserTaskExecutionView.chatTabName),
                      const Tab(text: UserTaskExecutionView.resultTabName),
                      Tab(
                          child: ds.Pills.primary(
                              type: ds.PillsType.fill,
                              alignment: AlignmentDirectional.topEnd,
                              visibility: userTaskExecution.nNotReadTodos > 0,
                              text: userTaskExecution.nNotReadTodos.toString(),
                              child: const Padding(
                                padding:
                                    EdgeInsets.all(ds.Spacing.smallPadding),
                                child: Text(UserTaskExecutionView.todosTabName),
                              )))
                    ],
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: ds
                            .DesignColor.primary.main, // Set the desired color.
                        width: 4.0, // Set the desired thickness.
                      ),
                    ),
                  ),
                  body: StreamBuilder<bool>(
                      stream: userTaskExecution.session.draftStartedStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.active &&
                            snapshot.data != null) {
                          if (snapshot.data == true) {
                            _onDraftGenerated();
                          }
                        }
                        return TabBarView(
                          physics: swipePhysics,
                          controller: _tabController,
                          children: [
                            ChangeNotifierProvider<Session>.value(
                              value: userTaskExecution.session,
                              child: ChatView(
                                  userTaskExecution: userTaskExecution,
                                  firstMessageToSend:
                                      widget.firstMessageToSend),
                            ),
                            ResultView(
                              userTaskExecution: userTaskExecution,
                              onEdit: () async {
                                await Microphone().record(
                                  filename: 'user_message',
                                );
                                _tabController.animateTo(0);
                              },
                              onTextEditAction: (
                                  {required String chatMessage,
                                  required int textEditActionPk}) async {
                                // Switch back to the chat
                                _tabController.animateTo(0);
                                // Call backend and execute text edit action
                                bool success =
                                    await userTaskExecution.runTextEditAction(
                                        textEditActionPk, chatMessage);
                                if (!success) {
                                  // 1. Remove 'waiting for mojo'
                                  userTaskExecution.session.waitingForMojo =
                                      false;
                                  // 2. Remove user_message
                                  userTaskExecution.session
                                      .removeLastUserMessage();
                                  // 3. reset tab controller result view
                                  _tabController.animateTo(1);

                                  // Note: then a socket error can occur => cf session.onSocketioError and userTaskExecution.reSubmit
                                }
                              },
                              onPredefinedActionSelected: () {
                                setState(() {
                                  _processing = !_processing;
                                });
                              },
                            ),
                            // ActionsView(userTaskExecution: widget.userTaskExecution),
                            UserTaskExecutionTodosList(
                                userTaskExecution: userTaskExecution)
                          ],
                        );
                      }),
                );
              });
        }),
      ),
    );
  }
}
