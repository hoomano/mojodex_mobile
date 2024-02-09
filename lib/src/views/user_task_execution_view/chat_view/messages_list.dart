import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../models/session/messages/message.dart';
import '../../../models/session/messages/user_message.dart';
import '../../../models/session/session.dart';
import 'message_placeholder.dart';
import 'message_widget.dart';

class MessagesList extends StatefulWidget {
  final Session session;
  final Function(UserMessage) onResubmit;

  MessagesList({super.key, required this.session, required this.onResubmit});

  @override
  State<MessagesList> createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList> {
  final bool autoPlay = true;

  int nMessagesLoadingBatchSize = 10;
  double lastScrollOffset = 0;

  bool processingRequest = false;

  ScrollController controller = ScrollController();

  Future<void> _loadMoreMessages({bool loadOlder = true}) async {
    if (processingRequest) return;
    processingRequest = true;
    await widget.session.loadMoreMessages(
        nMessages: nMessagesLoadingBatchSize, loadOlder: loadOlder);
    processingRequest = false;
    if (mounted) setState(() {});
  }

  void setStateIfMounted() {
    if (!mounted) return;
    setState(() {});
  }

  void onScrollChange() {
    lastScrollOffset = controller.offset;
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(onScrollChange);
    return;
  }

  @override
  void dispose() {
    controller.removeListener(onScrollChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (controller.hasClients) {
        controller.jumpTo(lastScrollOffset);
      }
    });
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return LazyLoadScrollView(
        scrollOffset: (constraints.maxHeight - 100).round(),
        onEndOfPage: () {
          _loadMoreMessages();
        },
        child: ListView.builder(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          reverse: true,
          padding: EdgeInsets.symmetric(horizontal: ds.Spacing.mediumPadding),
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          itemCount: widget.session.messages.length +
              1, // +1 for placeholder to be display in the same list as other messages
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Visibility(
                  visible: widget.session.waitingForMojo &&
                      !widget.session.loadingNewerMessages,
                  child: MessagePlaceholder(
                    stream: widget.session.mojoTokenStream,
                    onGoingMojoMessage: widget.session.onGoingMojoMessage,
                  ));
            }
            Message message = widget.session.messages[index - 1];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ChangeNotifierProvider<Message>.value(
                value: message,
                child: Consumer<Message>(builder:
                    (BuildContext context, Message message, Widget? child) {
                  return MessageWidget(
                    message: message,
                    onResubmit: () => widget.onResubmit(message as UserMessage),
                    correctSpell: (textPortion) =>
                        widget.session.correctSpell(textPortion),
                    streaming: widget.session.waitingForMojo,
                  );
                }),
              ),
            );
          },
        ),
      );
    });
  }
}
