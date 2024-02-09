import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:mojodex_mobile/src/views/widgets/voice_chat_bar.dart';

import '../../../DS/design_system.dart' as ds;
import '../../microphone.dart';

class TextAreaMic extends StatefulWidget {
  final Function({String? userText, String? audioFilePath}) onSubmit;
  final String filename;
  final bool enableText;
  final bool microAvailable;

  const TextAreaMic(
      {super.key,
      required this.onSubmit,
      required this.filename,
      this.microAvailable = false,
      this.enableText = false});

  @override
  State<StatefulWidget> createState() => TextAreaMicState();
}

class TextAreaMicState extends State<TextAreaMic> {
  FocusNode focusNode = FocusNode();
  TextEditingController textEditingController = TextEditingController();
  TextEditingController voiceEditingController = TextEditingController();

  bool showSubmitButton = false;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    textEditingController.addListener(onTextEditingControllerChange);
  }

  @override
  void dispose() {
    focusNode.removeListener(onFocusChange);
    textEditingController.removeListener(onTextEditingControllerChange);
    super.dispose();
  }

  void onTextEditingControllerChange() {
    setState(() {
      if (textEditingController.text.trim().isEmpty && !focusNode.hasFocus) {
        showSubmitButton = false;
      } else {
        showSubmitButton = true;
      }
    });
  }

  void onFocusChange() {
    setState(() {
      if (focusNode.hasFocus) {
        showSubmitButton = true;
      } else if (textEditingController.text.trim().isEmpty) {
        showSubmitButton = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Microphone().builder(context, builder: (context, state, mic) {
          return widget.enableText
              ? AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: state == RecorderState.recording ? 0 : 50,
                  child: Builder(builder: (context) {
                    if (state == RecorderState.recording) {
                      return const SizedBox.shrink();
                    }

                    return TextFormField(
                      focusNode: focusNode,
                      controller: textEditingController,
                      onTapOutside: (_) => [focusNode.unfocus()],
                      maxLines: 5,
                      onFieldSubmitted: (_) =>
                          widget.onSubmit(userText: textEditingController.text),
                      minLines: 1,
                      style: TextStyle(color: ds.DesignColor.grey.grey_9),
                      decoration: InputDecoration(
                          hintText: "hint text",
                          hintStyle:
                              TextStyle(color: ds.DesignColor.grey.grey_3),
                          filled: true,
                          enabled: true,
                          fillColor: ds.DesignColor.white,
                          border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              borderSide:
                                  const BorderSide(color: Color(0xFF879BB7)))),
                    );
                  }),
                )
              : const SizedBox.shrink();
        }),
        Visibility(
          visible: showSubmitButton,
          child: Padding(
            padding: const EdgeInsets.only(
                top: ds.Spacing.smallPadding, bottom: 10.0),
            child: ds.Button.fill(
              text: "Submit",
              onPressed: () =>
                  widget.onSubmit(userText: textEditingController.text),
            ),
          ),
        ),
        Visibility(
          visible: !showSubmitButton,
          child: Padding(
            padding: const EdgeInsets.all(ds.Spacing.smallPadding),
            child: VoiceChatBar(
                onSubmit: (audioFilePath) =>
                    widget.onSubmit(audioFilePath: audioFilePath),
                width: MediaQuery.of(context).size.width -
                    ds.Spacing.mediumPadding,
                onClickOnServiceInterrupted: () {},
                filename: widget.filename,
                microAvailable: widget.microAvailable),
          ),
        )
      ],
    );
  }
}
