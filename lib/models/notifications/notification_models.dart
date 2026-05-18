class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.createdAt,
    this.raw,
  });

  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? createdAt;
  final Map<String, dynamic>? raw;

  NotificationItem copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? raw,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      raw: raw ?? this.raw,
    );
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final id =
        (json['id'] ??
                json['_id'] ??
                json['uuid'] ??
                json['notificationId'] ??
                json['notification_id'])
            ?.toString() ??
        '';
    final type =
        (json['type'] ?? json['notificationType'] ?? json['notification_type'])
            ?.toString() ??
        'general';
    final title =
        (json['title'] ?? json['subject'] ?? json['heading'])?.toString() ??
        _titleFromType(type);
    final message =
        (json['message'] ?? json['body'] ?? json['description'])?.toString() ??
        '';
    final isReadRaw =
        json['isRead'] ?? json['read'] ?? json['is_read'] ?? false;
    final isRead = _toBool(isReadRaw);
    final createdAtRaw =
        json['createdAt'] ?? json['created_at'] ?? json['time'];

    return NotificationItem(
      id: id,
      type: type,
      title: title,
      message: message,
      isRead: isRead,
      createdAt: _toDateTime(createdAtRaw),
      raw: json,
    );
  }
}

class NotificationsPageData {
  const NotificationsPageData({
    required this.items,
    required this.unreadCount,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<NotificationItem> items;
  final int unreadCount;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
}

class NotificationsPageResult {
  const NotificationsPageResult({
    required this.success,
    required this.message,
    this.data,
    this.raw,
  });

  final bool success;
  final String message;
  final NotificationsPageData? data;
  final Map<String, dynamic>? raw;
}

class NotificationActionResult {
  const NotificationActionResult({
    required this.success,
    required this.message,
    this.raw,
  });

  final bool success;
  final String message;
  final Map<String, dynamic>? raw;
}

bool _toBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  final normalized = value?.toString().trim().toLowerCase();
  return normalized == 'true' || normalized == '1' || normalized == 'yes';
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  final text = value.toString().trim();
  if (text.isEmpty) {
    return null;
  }
  return DateTime.tryParse(text);
}

String _titleFromType(String type) {
  final normalized = type.trim().replaceAll('_', ' ');
  if (normalized.isEmpty) {
    return 'Notification';
  }
  return normalized[0].toUpperCase() + normalized.substring(1);
}
