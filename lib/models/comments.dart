import 'package:cloud_firestore/cloud_firestore.dart';

class Comments {
  final String profilePic;
  final String name;
  final String uid;
  final String text;
  final String commentId;
  final String postId;
  final String datePublished;
  final List<String> likes;

  const Comments({
    required this.profilePic,
    required this.name,
    required this.uid,
    required this.text,
    required this.commentId,
    required this.datePublished,
    required this.likes,
    required this.postId,
  });

  Map<String, dynamic> toJson() => {
    'profilePic': profilePic,
    'name': name,
    'uid': uid,
    'text': text,
    'commentId': commentId,
    'datePublished': datePublished,
    'likes': likes,
    'postId': postId,
  };

  static Comments fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Comments(
      profilePic: snapshot['profilePic'],
      uid: snapshot['uid'],
      name: snapshot['name'],
      text: snapshot['text'],
      datePublished: snapshot['datePublished'],
      commentId: snapshot['commentId'],
      likes: snapshot['likes'],
      postId: snapshot['postId'],
    );
  }
}
