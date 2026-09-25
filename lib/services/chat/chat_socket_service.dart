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

  // The chat list screen and every open conversation thread each used to
  // create their own ChatSocketService — meaning two (or more) separate
  // socket.io connections per session for no reason. This shared instance
  // is what every controller should use by default; only the explicit
  // constructor (for tests / DI) creates a standalone one. Lifecycle is
  // tied to the auth session, not to any one controller — see
  // [resetShared], called on logout.
  static ChatSocketService? _shared;
  static ChatSocketService get shared => _shared ??= ChatSocketService();

  /// Tears down and drops the shared instance. Call on logout — a fresh
  /// [shared] will be created (and can reconnect) the next time something
  /// asks for it, e.g. after a subsequent login.
  static void resetShared() {
    _shared?.dispose();
    _shared = null;
  }

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
  final _notificationCtrl =
      StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStatusCtrl =
      StreamController<bool>.broadcast();
  final _messagesDeliveredCtrl =
      StreamController<SocketReceiptEvent>.broadcast();
  final _messagesReadCtrl =
      StreamController<SocketReceiptEvent>.broadcast();
  final _messageDeletedCtrl =
      StreamController<SocketMessageDeletedEvent>.broadcast();
  final _presenceUpdateCtrl =
      StreamController<SocketPresenceEvent>.broadcast();

  Stream<ChatMessage> get onNewMessage => _newMessageCtrl.stream;
  Stream<Map<String, dynamic>> get onConversationUpdated =>
      _conversationUpdatedCtrl.stream;
  Stream<SocketTypingEvent> get onTyping => _typingCtrl.stream;
  /// Real-time app notifications (booking accepted, review received, etc.).
  /// Confirmed with backend: `conversation_updated` is also (separately)
  /// used to carry these, tagged `type: "notification"` — that variant is
  /// unwrapped and forwarded to this same stream by ChatController rather
  /// than being mishandled as a conversation change; this event name
  /// itself is untouched by that.
  Stream<Map<String, dynamic>> get onNotification => _notificationCtrl.stream;
  Stream<bool> get onConnectionStatus => _connectionStatusCtrl.stream;
  /// Fires when the recipient's app receives a message (single tick ->
  /// double tick, gray).
  Stream<SocketReceiptEvent> get onMessagesDelivered =>
      _messagesDeliveredCtrl.stream;
  /// Fires when the recipient actually opens the conversation (double
  /// tick -> double tick, blue/"seen").
  Stream<SocketReceiptEvent> get onMessagesRead => _messagesReadCtrl.stream;
  /// Fires on every participant's socket when a message is deleted by
  /// anyone in the conversation. A `conversation_updated` (with the
  /// preview/unread count already reconciled server-side) always follows
  /// right after — this event is for removing the message from an
  /// *already-open* thread; the list itself only needs to react to
  /// `conversation_updated`, not this.
  Stream<SocketMessageDeletedEvent> get onMessageDeleted =>
      _messageDeletedCtrl.stream;
  /// Fires on other participants' sockets both when a user connects
  /// (`isOnline: true`) and disconnects (`isOnline: false`, confirmed by
  /// backend — up to ~45s after an ungraceful disconnect, e.g. app killed
  /// or network drop, since it's driven by an unanswered heartbeat; not at
  /// all if the user has another device still connected, since presence is
  /// tracked per-user, not per-socket).
  Stream<SocketPresenceEvent> get onPresenceUpdate =>
      _presenceUpdateCtrl.stream;

  // ── Connect ──────────────────────────────────────────────────────────────
  void connect(String accessToken) {
    if (_connected) return;

    _socket = io.io(
      _socketUrl,
      io.OptionBuilder()
          // Deliberately NOT forcing transports to ['websocket'] here — this
          // server requires the initial HTTP polling handshake before the
          // upgrade to websocket (confirmed against the live server: a
          // websocket-only connection never even reaches the auth check and
          // fails at the transport layer). Let socket.io negotiate its
          // default ['polling', 'websocket'].
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
      ..on('user_typing', _handleUserTyping)
      ..on('user_stop_typing', _handleUserStopTyping)
      ..on('notification', _handleNotification)
      ..on('messages_delivered', _handleMessagesDelivered)
      ..on('messages_read', _handleMessagesRead)
      ..on('message_deleted', _handleMessageDeleted)
      ..on('presence_update', _handlePresenceUpdate);

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
  // Two distinct events per the server contract — no `isTyping` flag on the
  // payload, the event name itself carries that meaning.
  void emitTyping(String conversationId) {
    _socket?.emit('typing', {'conversationId': conversationId});
  }

  void emitStopTyping(String conversationId) {
    _socket?.emit('stop_typing', {'conversationId': conversationId});
  }

  // ── Event handlers ────────────────────────────────────────────────────────
  void _handleNewMessage(dynamic data) {
    if (data is! Map) return;
    final m = Map<String, dynamic>.from(data);
    // Originally this event only carried `conversation`, not
    // `conversationId` (every other event's field), which meant this
    // always resolved to '' and ChatMessagesController's
    // `if (msg.conversationId != conversationId)` silently dropped every
    // real-time message — see docs/backend-chat-socket-questions.md item
    // #1. Backend has since added `conversationId` here too (kept
    // `conversation` for REST-shape consistency); it's now the one key
    // that works on every chat event, so it's checked first, with the
    // original field kept as a fallback for safety.
    final conversationId =
        m['conversationId']?.toString() ?? m['conversation']?.toString() ?? '';
    final msg = ChatMessage.fromMap(m, conversationId);
    _newMessageCtrl.add(msg);
  }

  void _handleConversationUpdated(dynamic data) {
    if (data is Map) {
      _conversationUpdatedCtrl.add(Map<String, dynamic>.from(data));
    }
  }

  void _handleUserTyping(dynamic data) {
    if (data is! Map) return;
    _typingCtrl.add(SocketTypingEvent(
      conversationId: data['conversationId']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      isTyping: true,
    ));
  }

  void _handleUserStopTyping(dynamic data) {
    if (data is! Map) return;
    _typingCtrl.add(SocketTypingEvent(
      conversationId: data['conversationId']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      isTyping: false,
    ));
  }

  void _handleNotification(dynamic data) {
    if (data is Map) {
      _notificationCtrl.add(Map<String, dynamic>.from(data));
    }
  }

  void _handleMessagesDelivered(dynamic data) {
    if (data is! Map) return;
    final m = Map<String, dynamic>.from(data);
    _messagesDeliveredCtrl.add(SocketReceiptEvent(
      conversationId: m['conversationId']?.toString() ?? '',
      messageIds: _toStringList(m['messageIds']),
      at: _parseDate(m['deliveredAt']),
    ));
  }

  void _handleMessagesRead(dynamic data) {
    if (data is! Map) return;
    final m = Map<String, dynamic>.from(data);
    _messagesReadCtrl.add(SocketReceiptEvent(
      conversationId: m['conversationId']?.toString() ?? '',
      messageIds: _toStringList(m['messageIds']),
      at: _parseDate(m['readAt']),
    ));
  }

  void _handleMessageDeleted(dynamic data) {
    if (data is! Map) return;
    final m = Map<String, dynamic>.from(data);
    _messageDeletedCtrl.add(SocketMessageDeletedEvent(
      conversationId: m['conversationId']?.toString() ?? '',
      messageId: m['messageId']?.toString() ?? '',
      deletedBy: m['deletedBy']?.toString() ?? '',
    ));
  }

  void _handlePresenceUpdate(dynamic data) {
    if (data is! Map) return;
    final m = Map<String, dynamic>.from(data);
    _presenceUpdateCtrl.add(SocketPresenceEvent(
      userId: m['userId']?.toString() ?? '',
      isOnline: m['isOnline'] == true,
      lastSeenAt: _parseOptionalDate(m['lastSeenAt']),
    ));
  }

  static List<String> _toStringList(dynamic value) {
    if (value is! List) return const <String>[];
    return value.map((e) => e.toString()).toList(growable: false);
  }

  static DateTime _parseDate(dynamic raw) {
    if (raw == null) return DateTime.now();
    if (raw is DateTime) return raw;
    return DateTime.tryParse(raw.toString()) ?? DateTime.now();
  }

  static DateTime? _parseOptionalDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    return DateTime.tryParse(raw.toString());
  }

  // ── Dispose ───────────────────────────────────────────────────────────────
  void dispose() {
    disconnect();
    _newMessageCtrl.close();
    _conversationUpdatedCtrl.close();
    _typingCtrl.close();
    _notificationCtrl.close();
    _connectionStatusCtrl.close();
    _messagesDeliveredCtrl.close();
    _messagesReadCtrl.close();
    _messageDeletedCtrl.close();
    _presenceUpdateCtrl.close();
  }
}

class SocketReceiptEvent {
  const SocketReceiptEvent({
    required this.conversationId,
    required this.messageIds,
    required this.at,
  });
  final String conversationId;
  final List<String> messageIds;
  final DateTime at;
}

class SocketMessageDeletedEvent {
  const SocketMessageDeletedEvent({
    required this.conversationId,
    required this.messageId,
    required this.deletedBy,
  });
  final String conversationId;
  final String messageId;
  final String deletedBy;
}

class SocketPresenceEvent {
  const SocketPresenceEvent({
    required this.userId,
    required this.isOnline,
    this.lastSeenAt,
  });
  final String userId;
  final bool isOnline;
  final DateTime? lastSeenAt;
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
