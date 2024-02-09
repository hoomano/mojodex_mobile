import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mojodex_mobile/src/share_service.dart';
import 'package:mojodex_mobile/src/views/new_user_task_execution/task_card.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_view/chat_view/voice_message_audio_wave_form.dart';
import 'package:mojodex_mobile/src/views/user_task_execution_view/result_view/task_tool_results.dart';
import 'package:provider/provider.dart';

import '../../../../DS/design_system.dart' as ds;
import '../../../../DS/theme/themes.dart';
import '../../../models/language/system_language.dart';
import '../../../models/session/messages/audio_manager.dart';
import '../../../models/tasks/user_task.dart';
import '../../../models/tasks/user_task_execution.dart';
import '../../../models/user/user.dart';
import '../../../notifications_manager.dart';
import '../../widgets/correctable_text.dart';
import '../../widgets/spelling_corrector.dart';

// ignore: must_be_immutable
class ResultView extends StatefulWidget {
  final UserTaskExecution userTaskExecution;
  final Function onEdit;
  final Function({required String chatMessage, required int textEditActionPk})
      onTextEditAction;
  final Function onPredefinedActionSelected;
  bool isDrafting = true;
  bool noDraft = false;

  ResultView(
      {required this.userTaskExecution,
      required this.onEdit,
      required this.onTextEditAction,
      required this.onPredefinedActionSelected}) {
    isDrafting = userTaskExecution.session.mojoDrafting;
    noDraft = !isDrafting && userTaskExecution.producedText == null;
    if (userTaskExecution.producedText?.audioManager != null) {
      userTaskExecution.producedText!.audioManager!
          .initialize(playWhenInitialized: true);
    }
  }

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  late ScrollController _scrollController;

  get _buttonsEnabled =>
      !widget.isDrafting &&
      !widget.noDraft &&
      !widget.userTaskExecution.refreshing;

  String? _correctingSpellingText;
  bool shouldAutoScroll = true;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (shouldAutoScroll) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  void _shareWith(GlobalKey shareButtonKey) {
    ShareService.share(
      subject: widget.userTaskExecution.producedText!.title ?? "",
      key: shareButtonKey,
      text:
          "${widget.userTaskExecution.producedText!.title}\n\n${widget.userTaskExecution.producedText!.production}",
    );
  }

  void _onDraftCompleted(BuildContext context) {
    final labelsProvider = Provider.of<SystemLanguage>(context);
    widget.isDrafting = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.noDraft && User().notifAllowed == null) {
        ds.Modal(
          icon: labelsProvider.getText(
              key: "userTaskExecution.resultTab.notificationValidation.emoji"),
          title: labelsProvider.getText(
              key: "userTaskExecution.resultTab.notificationValidation.title"),
          textContent: labelsProvider.getText(
              key:
                  "userTaskExecution.resultTab.notificationValidation.textContent"),
          acceptButtonText: labelsProvider.getText(
              key:
                  "userTaskExecution.resultTab.notificationValidation.acceptButtonText"),
          onAccept: () {
            context.pop();
            NotificationsManager().askPermission();
          },
        ).show(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final labelsProvider = Provider.of<SystemLanguage>(context);
    final shareButtonKey = GlobalKey();

    Widget downloading = SizedBox(
      height: VoiceMessageAudioWaveForm.height,
      child: Align(
        alignment: Alignment.center,
        child: LinearProgressIndicator(
            color: ds.DesignColor.primary.main,
            backgroundColor: themeProvider.themeMode == ThemeMode.dark
                ? ds.DesignColor.grey.grey_7
                : ds.DesignColor.grey.grey_3,
            valueColor:
                AlwaysStoppedAnimation<Color>(ds.DesignColor.grey.grey_1)),
      ),
    );

    // Audio Player UI
    final audioPlayerUI = Padding(
      padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
      child: Consumer<AudioManager?>(builder:
          (BuildContext context, AudioManager? audioManager, Widget? child) {
        if (audioManager == null || audioManager.errorWithAudioFile) {
          return SizedBox(height: VoiceMessageAudioWaveForm.height);
        }
        if (!audioManager.initialized) {
          return downloading;
        }
        return VoiceMessageAudioWaveForm(
            audioManager: widget.userTaskExecution.producedText!.audioManager!,
            m4aFileInvalid: false,
            widgetColor: themeProvider.themeMode == ThemeMode.dark
                ? ds.DesignColor.grey.grey_1
                : ds.DesignColor.grey.grey_3,
            liveColor: themeProvider.themeMode == ThemeMode.dark
                ? ds.DesignColor.grey.grey_5
                : ds.DesignColor.grey.grey_7,
            backgroundColor: Colors.transparent);
      }),
    );

    List<TaskToolExecutionWidget> taskToolExecutionWidgets() {
      Map<String, int> indexTaskExecutionOfThisType = {};
      return widget.userTaskExecution.taskToolExecutions
          .map((taskToolExecution) {
        int totalTaskExecutionOfThisType = widget.userTaskExecution
                .nTaskToolExecutionTypes[taskToolExecution.tool.label] ??
            0;
        if (indexTaskExecutionOfThisType[taskToolExecution.tool.label] ==
            null) {
          indexTaskExecutionOfThisType[taskToolExecution.tool.label] = 0;
        } else {
          indexTaskExecutionOfThisType[taskToolExecution.tool.label] =
              indexTaskExecutionOfThisType[taskToolExecution.tool.label]! + 1;
        }

        return TaskToolExecutionWidget(
            taskToolExecution: taskToolExecution,
            index: indexTaskExecutionOfThisType[taskToolExecution.tool.label]!,
            total: totalTaskExecutionOfThisType);
      }).toList();
    }

    // Task Tool Results UI
    final taskToolResultsUI =
        widget.userTaskExecution.taskToolExecutions.isEmpty
            ? Container()
            : Padding(
                padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Sources",
                        style: TextStyle(
                            color: ds.DesignColor.grey.grey_3,
                            fontSize: ds.TextFontSize.h6,
                            fontWeight: FontWeight.bold)),
                    ds.Space.verticalMedium
                  ]..addAll(taskToolExecutionWidgets()),
                ),
              );

    // Buttons UI
    final buttonsUI = Padding(
      padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
      child: FractionallySizedBox(
        widthFactor: 1,
        child: Opacity(
          opacity: !_buttonsEnabled ? 0.2 : 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ds.Button.outline(
                  text:
                      "${labelsProvider.getText(key: "userTaskExecution.resultTab.editEmoji")} ${labelsProvider.getText(key: "userTaskExecution.resultTab.editButton")}",
                  backgroundColor: Colors.transparent,
                  textColor: themeProvider.themeMode == ThemeMode.dark
                      ? ds.DesignColor.grey.grey_1
                      : ds.DesignColor.grey.grey_9,
                  onPressed: !_buttonsEnabled ? null : () => widget.onEdit()),
              ds.Button.outline(
                  key: shareButtonKey,
                  backgroundColor: Colors.transparent,
                  textColor: themeProvider.themeMode == ThemeMode.dark
                      ? ds.DesignColor.grey.grey_1
                      : ds.DesignColor.grey.grey_9,
                  text: labelsProvider.getText(
                      key: "userTaskExecution.resultTab.exportButton"),
                  onPressed: !_buttonsEnabled
                      ? null
                      : () => _shareWith(shareButtonKey))
            ],
          ),
        ),
      ),
    );

    // Text Edit Actions Buttons UI
    final textEditActionButtonsUI = Padding(
      padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Opacity(
          opacity: !_buttonsEnabled ? 0.2 : 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                widget.userTaskExecution.textEditActions.map((editAction) {
              return AbsorbPointer(
                absorbing: !_buttonsEnabled,
                child: Padding(
                    padding:
                        const EdgeInsets.only(right: ds.Spacing.smallPadding),
                    child: ds.Button.outline(
                        backgroundColor: Colors.transparent,
                        textColor: themeProvider.themeMode == ThemeMode.dark
                            ? ds.DesignColor.grey.grey_1
                            : ds.DesignColor.grey.grey_9,
                        text: editAction.name,
                        onPressed: () => widget.onTextEditAction(
                            chatMessage: editAction.name,
                            textEditActionPk: editAction.textEditActionPk))),
              );
            }).toList(),
          ),
        ),
      ),
    );

    final predefinedActionsUI = Column(
        children: widget.userTaskExecution.predefinedActions.map((action) {
      UserTask? userTask =
          User().userTasksList.getUserTaskFromTaskPk(action.taskPk);
      return userTask != null && userTask.enabled
          ? AbsorbPointer(
              absorbing: !_buttonsEnabled,
              child: Opacity(
                opacity: !_buttonsEnabled ? 0.2 : 1,
                child: TaskCard(
                  userTask: userTask,
                  pushWithReplacement: true,
                  currentUserTaskExecution: widget.userTaskExecution,
                  firstMessageText:
                      "${action.messagePrefix}\n${widget.userTaskExecution.producedText?.production!}",
                  onProcessingChanged: () {
                    widget.onPredefinedActionSelected();
                  },
                  onBackFromPlanPage: () {
                    setState(() {});
                  }, //maybe it has turned enabled
                  userTaskExecutionFk: widget.userTaskExecution.pk,
                ),
              ),
            )
          : Container();
    }).toList());

    return StreamBuilder<Map<String, dynamic>?>(
        stream: widget.userTaskExecution.session.draftTokenStream,
        builder: (context, snapshot) {
          String producedText;
          String producedTextTitle;
          if (snapshot.connectionState == ConnectionState.active &&
              snapshot.data != null) {
            if (!snapshot.data!['done']) {
              producedTextTitle = snapshot.data!['title'] ?? "";
              producedText = snapshot.data!['text'] ?? "";
            } else {
              producedTextTitle = widget.userTaskExecution.producedText!.title!;
              producedText = widget.userTaskExecution.producedText!.production!;
              _onDraftCompleted(context);
            }
            if (widget.userTaskExecution.session.waitingForMojo) {
              _scrollToBottom();
            }
          } else {
            producedTextTitle =
                widget.userTaskExecution.session.onGoingDraftTitle ??
                    widget.userTaskExecution.producedText?.title ??
                    "";
            producedText =
                widget.userTaskExecution.session.onGoingDraftProduction ??
                    widget.userTaskExecution.producedText?.production ??
                    "";
          }
          return Stack(
            children: [
              NotificationListener<ScrollUpdateNotification>(
                onNotification: (notification) {
                  if (notification.dragDetails != null) {
                    if (shouldAutoScroll) {
                      setState(() {
                        shouldAutoScroll = false;
                      });
                    }
                  }
                  return true;
                },
                child: ListView(
                  controller: _scrollController,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(ds.Spacing.mediumPadding),
                        child: CorrectableText(
                            text: producedTextTitle,
                            textColor: themeProvider.themeMode == ThemeMode.dark
                                ? ds.DesignColor.grey.grey_1
                                : ds.DesignColor.grey.grey_9,
                            fontSize: ds.TextFontSize.h3,
                            textAlign: TextAlign.start,
                            editable: !widget
                                    .userTaskExecution.session.waitingForMojo &&
                                _buttonsEnabled,
                            onTap: (textToCorrect) {
                              widget.userTaskExecution.session
                                  .correctSpell(textToCorrect);
                              _correctingSpellingText = textToCorrect;
                              setState(() {});
                            })),
                    if (widget.userTaskExecution.producedText?.audioManager !=
                            null ||
                        widget.isDrafting)
                      ChangeNotifierProvider<AudioManager?>.value(
                          value: widget
                              .userTaskExecution.producedText?.audioManager,
                          child: audioPlayerUI),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: ds.Spacing.smallPadding),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                        color: themeProvider.themeMode == ThemeMode.dark
                            ? ds.DesignColor.grey.grey_7
                            : ds.DesignColor.grey.grey_1,
                        child: Column(
                          children: [
                            Padding(
                                padding: const EdgeInsets.all(
                                    ds.Spacing.largePadding),
                                child: producedText == ""
                                    ? Padding(
                                        padding: const EdgeInsets.all(
                                            ds.Spacing.smallPadding),
                                        child: LinearProgressIndicator(
                                            backgroundColor: themeProvider
                                                        .themeMode ==
                                                    ThemeMode.dark
                                                ? ds.DesignColor.grey.grey_7
                                                : ds.DesignColor.grey.grey_1,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(ds
                                                    .DesignColor.primary.main)),
                                      )
                                    : CorrectableText(
                                        text: producedText,
                                        textColor: themeProvider.themeMode ==
                                                ThemeMode.dark
                                            ? ds.DesignColor.grey.grey_1
                                            : ds.DesignColor.grey.grey_9,
                                        fontSize: ds.TextFontSize.body2,
                                        height: 1.6,
                                        editable: !widget.userTaskExecution
                                            .session.waitingForMojo,
                                        onTap: (textToCorrect) {
                                          widget.userTaskExecution.session
                                              .correctSpell(textToCorrect);
                                          _correctingSpellingText =
                                              textToCorrect;
                                          setState(() {});
                                        })),
                            taskToolResultsUI,
                            buttonsUI,
                            textEditActionButtonsUI
                          ],
                        ),
                      ),
                    ),
                    predefinedActionsUI,
                    if (widget.userTaskExecution.refreshing)
                      Padding(
                        padding: const EdgeInsets.all(ds.Spacing.smallPadding),
                        child: LinearProgressIndicator(
                          color: ds.DesignColor.primary.main,
                          backgroundColor:
                              themeProvider.themeMode == ThemeMode.dark
                                  ? ds.DesignColor.grey.grey_7
                                  : ds.DesignColor.grey.grey_3,
                        ),
                      )
                  ],
                ),
              ),
              if (_correctingSpellingText != null)
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? ds.DesignColor.grey.grey_9
                          : ds.DesignColor.white,
                      child: SpellingCorrector(
                          text: _correctingSpellingText!,
                          onFinishSpellingCorrection: (correctedText) {
                            widget.userTaskExecution.session
                                .onFinishSpellingCorrection(correctedText);
                            _correctingSpellingText = null;
                            setState(() {});
                          },
                          onDismissed: () {
                            _correctingSpellingText = null;
                            widget.userTaskExecution.session
                                .abandonSpellingCorrection();
                            setState(() {});
                          }),
                    ),
                  ],
                ),
            ],
          );
        });
  }
}
