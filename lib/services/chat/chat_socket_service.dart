import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:zip_peer/models/chat/chat_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  ChatSocketService
//  Manages the Socket.io connection and exposes typed stream callbacks.
// ─────────────────────────────────────────────────────────────────────────────
class ChatSocketService {
  /// Override with `--dart-define=SOCKET_URL=https://...`.
  ///
  /// Defaults to the REST host, which is App Runner — and App Runner cannot carry a socket at all
  /// (see below). Keeping this a build flag means moving to the WebSocket-capable host costs a
  /// rebuild rather than a code change and a review.
  static const String _socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'https://au2p3vkiqi.us-east-1.awsapprunner.com',
  );

  /// Enable with `--dart-define=SOCKET_ENABLED=true`, together with a `SOCKET_URL` that can actually
  /// carry a WebSocket. Off by default, and that default is correct for the current host.
  ///
  /// App Runner rejects the WebSocket upgrade at its proxy, before the Node process sees it, and on
  /// native platforms this client can only ever speak WebSocket (see the long comment in [connect]) —
  /// so against App Runner the socket cannot connect at all, and connecting would only burn battery
  /// on five guaranteed failures every time a chat screen opens. Chat falls back to REST polling
  /// (ChatController / ChatMessagesController / BottomNavController) while this is false.
  ///
  /// The replacement host is further along than it used to be. Verified against the ALB in front of
  /// the ECS service on 2026-10-07: health 200, socket.io polling handshake fine, and the WebSocket
  /// upgrade answered **HTTP 101 Switching Protocols** — the exact thing App Runner refuses. What is
  /// still missing is TLS, because the ALB has no certificate and the account has no domain yet. A
  /// CloudFront distribution in front of the ALB would supply a trusted `*.cloudfront.net`
  /// certificate and carries WebSocket natively, which is the intended fix; it is awaiting approval.
  ///
  /// So: once there is a `wss://`-capable origin, set both defines. No code change is needed here,
  /// and the forced `transports`/`upgrade` options in [connect] can come out at the same time.
  static const bool socketEnabled = bool.fromEnvironment('SOCKET_ENABLED');

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
    if (!socketEnabled || _connected) return;

    // ROOT CAUSE OF THE "chat doesn't update live" REPORT (found 2026-09-25,
    // confirmed on-device with a real socket, not just reading source):
    // socket_io_client's IO/native platform transport factory
    // (lib/src/engine/transport/io_transports.dart, unchanged in both
    // 2.0.3+1 — what this app uses — and the newer 3.1.6) hardcodes:
    //   Transport newInstance(String name, options) {
    //     // only support websocket here.
    //     return IOWebSocketTransport(options);
    //   }
    // It ignores `name` and ALWAYS opens a raw WebSocket, on every Android/
    // iOS build, no matter what `transports`/`upgrade` are set to — proper
    // HTTP long-polling is only implemented for the web/browser build of
    // this package. That's fine against most socket.io servers (which
    // happily accept a direct WebSocket connection), but this specific
    // backend's infrastructure (AWS App Runner) rejects the raw upgrade
    // handshake with HTTP 403 — so on native, the socket can never connect
    // at all, regardless of any option here. `transports`/`upgrade` below
    // are kept for correctness (and in case this backend or a future
    // package version stops requiring the polling-first dance) but they
    // do NOT currently change native behavior — see
    // docs/backend-chat-socket-questions.md for the actual fix needed
    // (App Runner/infra allowing a direct WebSocket upgrade).
    final options = io.OptionBuilder()
        .setTransports(['polling'])
        .disableAutoConnect()
        .setAuth({'token': accessToken})
        .setReconnectionAttempts(5)
        .setReconnectionDelay(2000)
        .build();
    options['upgrade'] = false;

    _socket = io.io(_socketUrl, options);

    _socket!
      ..onConnect((_) {
        debugPrint('[ChatSocket] CONNECTED sid=${_socket?.id}');
        _connected = true;
        _connectionStatusCtrl.add(true);
      })
      ..onDisconnect((reason) {
        debugPrint('[ChatSocket] DISCONNECTED reason=$reason');
        _connected = false;
        _connectionStatusCtrl.add(false);
      })
      ..onConnectError((err) {
        debugPrint('[ChatSocket] CONNECT ERROR: $err');
        _connected = false;
        _connectionStatusCtrl.add(false);
      })
      ..onError((err) {
        debugPrint('[ChatSocket] SOCKET ERROR: $err');
      })
      ..on('new_message', _handleNewMessage)
      ..on('conversation_updated', _handleConversationUpdated)
      ..on('user_typing', _handleUserTyping)
      ..on('user_stop_typing', _handleUserStopTyping)
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
    if (data is! Map) return;
    final map = Map<String, dynamic>.from(data);

    // There is no `notification` socket event — confirmed against the server's emit sites. In-app
    // notifications arrive here instead, as conversation_updated with type: "notification" and the
    // row nested under `notification`. Routing them across is what makes [onNotification] fire at
    // all: a direct .on('notification') listener sits silent forever, because nothing emits it.
    if (map['type'] == 'notification') {
      final row = notificationRowFrom(map);
      if (row != null) _notificationCtrl.add(row);
      return;
    }

    _conversationUpdatedCtrl.add(map);
  }

  /// Pulls the notification row out of a `conversation_updated` event.
  ///
  /// Exposed for tests because the extraction is the whole behaviour: the row is nested one level
  /// down, and reading the wrong level yields a NotificationItem with an empty id, which the
  /// controller silently drops. That failure looks exactly like "no notifications arrived".
  @visibleForTesting
  static Map<String, dynamic>? notificationRowFrom(Map<String, dynamic> event) {
    final nested = event['notification'];
    return nested is Map ? Map<String, dynamic>.from(nested) : null;
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
