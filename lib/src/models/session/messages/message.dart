import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../../http_caller.dart';
import '../../user/user.dart';
import 'audio_manager.dart';

enum MessageSender { user, agent }

abstract class Message extends ChangeNotifier with HttpCaller {
  // Logger
  final Logger logger = Logger('Message');

  /// this is the primary key of the message in the backend database
  late int _messagePk;

  /// Bool has message pk been initialized (= received from backend)
  bool _hasMessagePk = false;
  bool get hasMessagePk => _hasMessagePk;

  int get messagePk => _messagePk;
  set messagePk(int messagePk) {
    _messagePk = messagePk;
    _hasMessagePk = true;
  }

  /// Message's sender
  late MessageSender sender;

  /// Has the message a corresponding audio file stored in backend ?
  late bool hasAudio;

  /// this is the text content of a message
  late String text;

  /// Should this message's audio be autoplayed if it has voice ?
  late bool autoPlay;

  /// Whether or not transcript has been received
  bool hasTranscript = false;

  /// Whether the backend confirm receiving the message
  late bool acked;

  /// Function to know whether or not the message was sent by user
  bool get sentByUser => sender == MessageSender.user;

  /// Whether message emission failed or not
  bool emissionFailed = false;

  /// Whether this message is the current userMessage being processed
  bool isCurrentProcessingUserMessage = false;

  /// Get local audio file path
  String get localAudioPath => isCurrentProcessingUserMessage
      ? '${User().appDocPath}/user_message.m4a'
      : '${User().appDocPath}/$messagePk.m4a';

  AudioManager? audioManager;

  Message(
      {required this.sender, this.hasAudio = false, this.autoPlay = false}) {
    if (hasAudio) {
      audioManager = AudioManager(getAudioFile: () async => localAudioPath);
    }
  }

  Message.fromJson(Map<String, dynamic> data) {
    /// [
    ///   {
    ///     message_pk: 19175,
    ///     sender: mojo,
    ///     message: {
    ///       text: Please provide me with the information about the meeting, such as the date, time, attendees, and key points discussed, so I can help you prepare the meeting minutes. Is there any additional information you'd like to include?,
    ///     },
    ///     audio: true
    ///   }
    /// ]
    messagePk = data['message_pk'];
    sender =
        data['sender'] == 'mojo' ? MessageSender.agent : MessageSender.user;
    if (data['message'].containsKey('text')) {
      text = data['message']['text'];
      hasTranscript = true;
    } else {
      hasTranscript = false;
    }

    hasAudio = data['audio'];
    if (hasAudio) {
      audioManager = AudioManager(getAudioFile: getVoice);
    }
    acked = true;
    autoPlay = false;
    emissionFailed = data['in_error_state'];
  }

  /// Get the audio file corresponding to the message from backend
  Future<String?> getVoice({int retry = 3}) async {
    try {
      // Prepare to write the file in a directory
      var file = File(localAudioPath);
      // Delete if one with same name already exists
      if (file.existsSync()) file.deleteSync();
      // Write the result in a file
      var ios = file.openWrite(mode: FileMode.append);

      String params =
          "datetime=${DateTime.now().toIso8601String()}&token=${User().tokenBackendPython!}&platform=mobile&version=${dotenv.env['VERSION']}";
      params = "$params&message_pk=$messagePk";

      http.Response? response =
          await getBytes(service: "voice", params: params);
      if (response == null) return null;

      // is response a json ?
      if (response.headers['content-type']!.contains('application/json')) {
        Map<String, dynamic> body = json.decode(response.body);
        if (body.containsKey("status") &&
            body["status"] == "processing" &&
            retry > 0) {
          logger.info(
              "🔁 _sendUserMessage: received response 'processing' - retry ${retry - 1}");
          await Future.delayed(const Duration(seconds: 1));
          return await getVoice(retry: retry - 1);
        }
      } else {
        Uint8List bytes = response.bodyBytes;
        ios.add(bytes);
        await ios.flush();
        await ios.close();
        return file.path;
      }
    } catch (e) {
      logger.shout("Error in _getVoice exception: $e");
    }
    return null;
  }
}
