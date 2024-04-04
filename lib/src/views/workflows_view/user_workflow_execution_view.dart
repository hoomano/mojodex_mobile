import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/views/widgets/common_scaffold.dart';
import 'package:mojodex_mobile/src/views/workflows_view/chat_view/chat_view.dart';
import 'package:mojodex_mobile/src/views/workflows_view/process_view/process_view.dart';
import 'package:mojodex_mobile/src/views/workflows_view/result_view/result_view.dart';
import 'package:provider/provider.dart';

import '../../../DS/design_system.dart' as ds;
import '../../microphone.dart';
import '../../models/session/session.dart';
import '../../models/workflows/user_worklow_execution.dart';
import 'deleted_user_workflow_execution.dart';

class UserWorkflowExecutionView extends StatefulWidget {
  static const String routeName = "user_workflow_execution";
  static const chatTabName = 'Chat';
  static const processTabName = 'Process';
  static const resultTabName = 'Result';

  final UserWorkflowExecution userWorkflowExecution;
  final String initialTab;

  // userWorkflowExecution should be refreshed onlyif it's not a new one
  final bool refreshUserWorkflowExecution;

  const UserWorkflowExecutionView(
      {super.key,
      required this.userWorkflowExecution,
      this.initialTab = processTabName,
      this.refreshUserWorkflowExecution = true});

  @override
  State<UserWorkflowExecutionView> createState() =>
      _UserWorkflowExecutionViewState();
}

class _UserWorkflowExecutionViewState extends State<UserWorkflowExecutionView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool get processTabEnabled => true;
  bool get resultTabEnabled => false;

  @override
  void initState() {
    super.initState();
    // if session is not already connected, connect to it
    widget.userWorkflowExecution.session.connectToSession();

    // refresh userWorkflowExecution
    if (widget.refreshUserWorkflowExecution) {
      widget.userWorkflowExecution.refresh();
    }

    _tabController = TabController(vsync: this, length: 3);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialTab == UserWorkflowExecutionView.chatTabName) {
        _tabController.animateTo(0);
      } else if (widget.initialTab ==
          UserWorkflowExecutionView.processTabName) {
        _tabController.animateTo(1);
      } else if (widget.initialTab == UserWorkflowExecutionView.resultTabName) {
        _tabController.animateTo(2);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserWorkflowExecution>.value(
        value: widget.userWorkflowExecution,
        child: Consumer<UserWorkflowExecution>(
            builder: (context, userWorkflowExecution, child) {
          if (userWorkflowExecution.deletedByUser) {
            return DeletedUserWorkflowExecution();
          }
          if (!userWorkflowExecution.waitingForValidation &&
              _tabController.index != 1) {
            _tabController.animateTo(1);
          }
          if (userWorkflowExecution.producedText != null &&
              _tabController.index != 2) {
            _tabController.animateTo(2);
          }
          return MojodexScaffold(
            appBarTitle: "Workflow ${userWorkflowExecution.pk}",
            safeAreaOverflow: false,
            appBarBottom: TabBar(
              labelColor: ds.DesignColor.white,
              unselectedLabelColor:
                  (_tabController.index == 0 && !resultTabEnabled)
                      ? ds.DesignColor.grey.grey_5
                      : ds.DesignColor.grey.grey_1,
              controller: _tabController,
              tabs: const [
                Tab(text: UserWorkflowExecutionView.chatTabName),
                Tab(text: UserWorkflowExecutionView.processTabName),
                Tab(text: UserWorkflowExecutionView.resultTabName),
              ],
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  color: ds.DesignColor.primary.main, // Set the desired color.
                  width: 4.0, // Set the desired thickness.
                ),
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                ChangeNotifierProvider<Session>.value(
                  value: userWorkflowExecution.session,
                  child: ChatView(userWorkflowExecution: userWorkflowExecution),
                ),
                ProcessView(
                  userWorkflowExecution: userWorkflowExecution,
                  onReject: () async {
                    await Microphone().record(
                      filename: 'user_message',
                    );
                    //userWorkflowExecution.session.waitingForMojo = true;
                    _tabController.animateTo(0);
                  },
                ),
                ResultView(userWorkflowExecution: userWorkflowExecution)
              ],
            ),
          );
        }));
  }
}
