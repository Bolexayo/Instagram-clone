import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatTimestamp(dynamic dateInput, {bool isComment = false}) {
  DateTime date;

  // 1. Convert the String (or Timestamp) to DateTime
  if (dateInput is String) {
    date = DateTime.parse(dateInput);
  } else if (dateInput is Timestamp) {
    date = dateInput.toDate();
  } else {
    date = DateTime.now(); // Fallback
  }

  final now = DateTime.now();
  final difference = now.difference(date);

  if (isComment) {
    // --- COMMENT FORMAT (Short) ---
    if (difference.inMinutes < 1) return 'now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';
    return '${(difference.inDays / 7).floor()}w';
  } else {
    // --- POST FORMAT (Long) ---
    if (difference.inDays < 7) {
      if (difference.inDays == 0) {
        if (difference.inHours == 0)
          return '${difference.inMinutes} minutes ago';
        return '${difference.inHours} hours ago';
      }
      return '${difference.inDays} days ago';
    } else {
      // Format
      return DateFormat('d MMMM').format(date);
    }
  }
}
