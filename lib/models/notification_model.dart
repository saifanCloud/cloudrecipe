class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.isRead = false,
  });
}