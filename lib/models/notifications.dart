class NotificationModel {
  final bool isSeen;
  final String type; // 'like' or 'follow'
  final String senderId;
  final String senderName;
  final String senderProfilePic;
  final String? postId; // Only for likes
  final String? postImage; // Only for likes
  final DateTime timestamp;

  NotificationModel({
    this.isSeen = false,
    required this.type,
    required this.senderId,
    required this.senderName,
    required this.senderProfilePic,
    this.postId,
    this.postImage,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'isSeen': isSeen,
    'type': type,
    'senderId': senderId,
    'senderName': senderName,
    'senderProfilePic': senderProfilePic,
    'postId': postId,
    'postImage': postImage,
    'timestamp': timestamp,
  };
}
