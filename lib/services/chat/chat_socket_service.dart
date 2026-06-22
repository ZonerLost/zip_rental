import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:zip_peer/models/chat/chat_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  ChatSocketService
//  Manages the Socket.io connection and exposes typed stream callbacks.
// ─────────────────────────────────────────────────────────────────────────────
class ChatSocketService {
  static const String _socketUrl =
      'https://au2p3vkiqi.us-east-1.awsapprunner.com';

  io.Socket? _socket;
  bool _connected = false;

  bool get isConnected => _connected;

  // Stream controllers — callers subscribe to these
  final _newMessageCtrl =
      StreamController<ChatMessage>.broadcast();
  final _conversationUpdatedCtrl =
      StreamController<Map<String, dynamic>>.broadcast();
  final _typingCtrl =
      StreamController<SocketTypingEvent>.broadcast();
  final _connectionStatusCtrl =
      StreamController<bool>.broadcast();

  Stream<ChatMessage> get onNewMessage => _newMessageCtrl.stream;
  Stream<Map<String, dynamic>> get onConversationUpdated =>
      _conversationUpdatedCtrl.stream;
  Stream<SocketTypingEvent> get onTyping => _typingCtrl.stream;
  Stream<bool> get onConnectionStatus => _connectionStatusCtrl.stream;

  // ── Connect ──────────────────────────────────────────────────────────────
  void connect(String accessToken) {
    if (_connected) return;

    _socket = io.io(
      _socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': accessToken})
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!
      ..onConnect((_) {
        _connected = true;
        _connectionStatusCtrl.add(true);
      })
      ..onDisconnect((_) {
        _connected = false;
        _connectionStatusCtrl.add(false);
      })
      ..onConnectError((_) {
        _connected = false;
        _connectionStatusCtrl.add(false);
      })
      ..on('new_message', _handleNewMessage)
      ..on('conversation_updated', _handleConversationUpdated)
      ..on('typing', _handleTyping)
      ..on('notification', _handleNotification);

    _socket!.connect();
  }

  // ── Disconnect ───────────────────────────────────────────────────────────
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connected = false;
  }

  // ── Room management ──────────────────────────────────────────────────────
  void joinConversation(String conversationId) {
    _socket?.emit('join_conversation', {'conversationId': conversationId});
  }

  void leaveConversation(String conversationId) {
    _socket?.emit('leave_conversation', {'conversationId': conversationId});
  }

  // ── Typing indicator ─────────────────────────────────────────────────────
  void emitTyping({
    required String conversationId,
    required bool isTyping,
  }) {
    _socket?.emit('typing', {
      'conversationId': conversationId,
      'isTyping': isTyping,
    });
  }

  // ── Event handlers ────────────────────────────────────────────────────────
  void _handleNewMessage(dynamic data) {
    if (data is! Map) return;
    final m = Map<String, dynamic>.from(data);
    final conversationId =
        m['conversationId']?.toString() ?? '';
    final msg = ChatMessage.fromMap(m, conversationId);
    _newMessageCtrl.add(msg);
  }

  void _handleConversationUpdated(dynamic data) {
    if (data is Map) {
      _conversationUpdatedCtrl.add(Map<String, dynamic>.from(data));
    }
  }

  void _handleTyping(dynamic data) {
    if (data is! Map) return;
    _typingCtrl.add(SocketTypingEvent(
      conversationId: data['conversationId']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      isTyping: data['isTyping'] == true,
    ));
  }

  void _handleNotification(dynamic data) {
    // Push this into conversation_updated so the list refreshes
    if (data is Map) {
      _conversationUpdatedCtrl.add(Map<String, dynamic>.from(data));
    }
  }

  // ── Dispose ───────────────────────────────────────────────────────────────
  void dispose() {
    disconnect();
    _newMessageCtrl.close();
    _conversationUpdatedCtrl.close();
    _typingCtrl.close();
    _connectionStatusCtrl.close();
  }
}

class SocketTypingEvent {
  const SocketTypingEvent({
    required this.conversationId,
    required this.userId,
    required this.isTyping,
  });
  final String conversationId;
  final String userId;
  final bool isTyping;
}
