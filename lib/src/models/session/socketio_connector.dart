import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/session/session.dart';
import 'package:mojodex_mobile/src/models/session/task_session.dart';
import 'package:mojodex_mobile/src/models/session/workflow_session.dart';
import 'package:mojodex_mobile/src/models/status_bar/calendar_suggestion.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../user/user.dart';

enum ConnectionStatus { connecting, connected, disconnected, error }

class SocketioConnector {
  // Logger
  final Logger logger = Logger('SocketioConnector');

  // Unique instance of the class
  static final SocketioConnector _instance =
      SocketioConnector.privateConstructor();

  // Private constructor of the class, called once when the class is created
  SocketioConnector.privateConstructor() {
    _initialize();
  }

  factory SocketioConnector() => _instance;

  List<Session> activeSessions = [];

  List<Session> _getSessionFromId(String sessionId) {
    return activeSessions
        .where((element) => element.sessionId == sessionId)
        .toList();
  }

  /// List of all the events to listen
  static const String _errorEventKey = 'error';
  static const String _userMessageReceptionEventKey = 'user_message_reception';
  static const String _userTaskExecutionTitleEventKey =
      'user_task_execution_title';
  static const String _draftTokenEventKey = "draft_token";
  static const String _draftMessageEventKey = "draft_message";
  static const String _mojoTokenEventKey = "mojo_token";
  static const String _mojoMessageEventKey = 'mojo_message';
  static const String _calendarSuggestionEventKey = "calendar_suggestion";
  static const String _userTaskExecutionStartEventKey =
      "user_task_execution_start";
  static const String _workflowStepExecutionInvalidatedEventKey =
      "workflow_step_execution_invalidated";
  static const String _workflowStepExecutionStartedEventKey =
      "workflow_step_execution_started";
  static const String _workflowStepExecutionEndedEventKey =
      "workflow_step_execution_ended";

  /// List of all the events to emit to
  static const String _leaveSessionEventKey = 'leave_session';
  static const String _startSessionEventKey = 'start_session';
  static const String _userMessageEventKey = 'user_message';

  /// this is the socket instance
  final Socket _socket = io(
      "${dotenv.env['BACKEND_URI']}",
      OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': User().tokenBackendPython!})
          .build());

  static final StreamController<ConnectionStatus> _connectionStatusController =
      StreamController.broadcast();
  Stream<ConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

  /// Current connection status
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  ConnectionStatus get connectionStatus => _connectionStatus;

  /// Function to call once the socket is connected
  void onConnect() {
    if (_connectionStatus == ConnectionStatus.connected) {
      logger.info("Already connected");
      _onMultipleConnect();
    }
    _updateConnectionStatus(ConnectionStatus.connected);
    logger.info("Connected");
    for (Session session in activeSessions) {
      _startSession(session);
    }
  }

  /// Function to call when the socket disconnects
  void onDisconnect() {
    logger.info("❌ disconnected ❌");
    _updateConnectionStatus(ConnectionStatus.disconnected);
    reconnect();
  }

  /// Function to call when the connection fails
  void onConnectionError(data) {
    logger.info("❌ connection error: $data");
    _updateConnectionStatus(ConnectionStatus.error);
    reconnect();
  }

  /// on error callback
  void _errorCallback(data) {
    logger.info("error: $data");
    if (data is Map &&
        data.containsKey('message') &&
        data['message'] == "Expired token") {
      _expiredTokenEvent();
      return;
    }
    try {
      List<Session> sessions = _getSessionFromId(data['session_id']);
      for (Session session in sessions) {
        session.onSocketioError(data);
      }
    } catch (e) {
      logger.shout("Error in error callback: $e");
    }
  }

  /// on user message acked callback
  void _userMessageAcked(data) {
    try {
      List<Session> sessions = _getSessionFromId(data['session_id']);
      for (Session s in sessions) {
        s.onUserMessageAcked(data);
      }
    } catch (e) {
      logger.shout("Error in user message ack callback: $e");
    }
  }

  /// on user task execution title callback
  void _userTaskExecutionTitle(data) {
    try {
      List<Session> sessions = _getSessionFromId(data['session_id']);
      for (Session s in sessions) {
        try {
          TaskSession session = s as TaskSession;
          session.onUserTaskExecutionTitle(data);
        } catch (e) {
          // Do nothing
        }
      }
    } catch (e) {
      logger.shout("Error in user_task_execution title callback: $e");
    }
  }

  /// on draft token callback
  void _draftTokenCallback(data) {
    try {
      List<Session> sessions = _getSessionFromId(data['session_id']);
      for (Session s in sessions) {
        try {
          TaskSession session = s as TaskSession;
          session.onDraftToken(data);
        } catch (e) {
          // If this doesn't work, probably the session is not a task session
          // let's stream it as a Mojo Message
          _mojoTokenCallback(data);
        }
      }
    } catch (e) {
      logger.shout("Error in draft token callback: $e");
    }
  }

  /// on draft message callback
  void _draftMessageCallback(data) {
    try {
      List<Session> sessions = _getSessionFromId(data[0]['session_id']);
      for (Session s in sessions) {
        try {
          TaskSession session = s as TaskSession;
          session.onReceivedDraft(data);
        } catch (e) {
          // If this doesn't work, probably the session is not a task session
          // let's write it as a Mojo Message
          _mojoMessageCallback(data);
        }
      }
    } catch (e) {
      logger.shout("Error in draft message callback: $e");
    }
  }

  /// on mojo token callback
  void _mojoTokenCallback(data) {
    try {
      List<Session> sessions = _getSessionFromId(data['session_id']);
      for (Session s in sessions) {
        s.onMojoToken(data);
      }
    } catch (e) {
      logger.shout("Error in mojo token callback: $e");
    }
  }

  /// on mojo message callback
  void _mojoMessageCallback(data) {
    try {
      List<Session> sessions = _getSessionFromId(data[0]['session_id']);
      for (Session s in sessions) {
        s.onMojoMessage(data);
      }
    } catch (e) {
      logger.shout("Error in mojo message callback: $e");
    }
  }

  void _calendarSuggestionCallback(data) {
    CalendarSuggestion().retrieveSuggestion(data);
  }

  void _userTaskExecutionStartCallback(data) async {
    try {
      List<Session> sessions = _getSessionFromId(data['session_id']);
      for (Session s in sessions) {
        try {
          TaskSession session = s as TaskSession;
          session.onUserTaskExecutionStartedCallback(data);
        } catch (e) {
          //do nothing
        }
      }
    } catch (e) {
      logger.shout("Error in user_task_execution start callback: $e");
    }
  }

  void _workflowStepExecutionInvalidatedCallback(data) {
    try {
      print("🟢 workflowStepExecutionInvalidatedCallback");
      List<Session> sessions = _getSessionFromId(data['session_id']);
      for (Session s in sessions) {
        try {
          WorkflowSession session = s as WorkflowSession;
          session.onWorkflowStepExecutionInvalidatedCallback(data);
        } catch (e) {
          //do nothing
        }
      }
    } catch (e) {
      logger.shout("Error in workflow step initialized callback: $e");
    }
  }

  void _workflowStepExecutionStartedCallback(data) {
    try {
      List<Session> sessions = _getSessionFromId(data['session_id']);
      for (Session s in sessions) {
        try {
          WorkflowSession session = s as WorkflowSession;
          session.onNewWorkflowStepExecutionCallback(data);
        } catch (e) {
          //do nothing
        }
      }
    } catch (e) {
      logger.shout("Error in workflow step started callback: $e");
    }
  }

  void _workflowStepExecutionEndedCallback(data) {
    try {
      List<Session> sessions = _getSessionFromId(data['session_id']);
      for (Session s in sessions) {
        try {
          WorkflowSession session = s as WorkflowSession;
          session.onWorkflowStepExecutionEndedCallback(data);
        } catch (e) {
          //do nothing
        }
      }
    } catch (e) {
      logger.shout("Error in workflow step ended callback: $e");
    }
  }

  void _onMultipleConnect() {
    logger.info("👉 multiple connect");
  }

  void _updateConnectionStatus(ConnectionStatus status) {
    _connectionStatus = status;
    _connectionStatusController.add(status);
  }

  void _expiredTokenEvent() {
    logger.info("❌ expired token ❌");
    _updateConnectionStatus(ConnectionStatus.error);
    User().logout();
  }

  /// initialize the socket configuration
  void _initialize() {
    _socket.onConnect((data) {
      onConnect();
    });

    _socket.onConnectError((data) {
      onConnectionError(data);
    });
    _updateConnectionStatus(ConnectionStatus.connecting);
    _connect();
  }

  /// Listen to all the events
  void _listenToEvents() {
    _socket.on(_errorEventKey, _errorCallback);
    _socket.on(_userMessageReceptionEventKey, _userMessageAcked);
    _socket.on(_userTaskExecutionTitleEventKey, _userTaskExecutionTitle);
    _socket.on(_draftTokenEventKey, _draftTokenCallback);
    _socket.on(_draftMessageEventKey, _draftMessageCallback);
    _socket.on(_mojoTokenEventKey, _mojoTokenCallback);
    _socket.on(_mojoMessageEventKey, _mojoMessageCallback);
    _socket.on(_calendarSuggestionEventKey, _calendarSuggestionCallback);
    _socket.on(
        _userTaskExecutionStartEventKey, _userTaskExecutionStartCallback);
    _socket.on(_workflowStepExecutionInvalidatedEventKey,
        _workflowStepExecutionInvalidatedCallback);
    _socket.on(_workflowStepExecutionStartedEventKey,
        _workflowStepExecutionStartedCallback);
    _socket.on(_workflowStepExecutionEndedEventKey,
        _workflowStepExecutionEndedCallback);
  }

  /// Connect to the socket
  void _connect() {
    _listenToEvents();
    _socket.connect();
  }

  /// Connect and send "start_session" event to connect to the room dedicated to session
  void connectSession(Session session) {
    activeSessions.add(session);
    if (_connectionStatus != ConnectionStatus.connected) {
      _connect();
    } else {
      _startSession(session);
    }
  }

  // Reconnect same current session after a disconnection
  void reconnect() {
    _connect();
  }

  void _startSession(Session session) {
    _emit(_startSessionEventKey, {"session_id": session.sessionId});
    logger.info(
        "🔌 Starting session ${session.sessionId} - messages: ${session.messages.length}");
  }

  void _emit(String eventName, Map<String, dynamic> message) {
    message['version'] = "${dotenv.env['VERSION']}";
    message['timezone_offset'] = "${-DateTime.now().timeZoneOffset.inMinutes}";
    _socket.emitWithAck(eventName, message);
  }

  void emitUserMessage(Map<String, dynamic> message) {
    _emit(_userMessageEventKey, message);
  }

  /// Disconnect from the socket
  /// Should not be used => never disconnect socket !
  void _disconnect() {
    _socket.close();
    _socket.destroy();
    onDisconnect();
    _updateConnectionStatus(ConnectionStatus.disconnected);
  }
}
