import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/models/comments.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //upload post
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profImage,
  ) async {
    String res = 'Some error occurred';
    try {
      String PhotoUrl = await StorageMethods().uploadImageToStorage(
        'posts',
        file,
        true,
      );

      String postId = const Uuid().v1(); // creates unique id based on time
      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        postId: postId,
        datePublished: DateTime.now().toString(),
        postUrl: PhotoUrl,
        profileImage: profImage,
        likes: [],
      );

      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> likePost(
    String postId,
    String uid,
    List likes,
    String postOwnerId,
    String postImage,
    String username,
    String profImage,
  ) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });

        //NOTIFICATION LOGIC
        if (uid != postOwnerId) {
          await _firestore
              .collection('users')
              .doc(postOwnerId)
              .collection('notifications')
              .add({
                'isSeen': false,
                'type': 'like',
                'senderId': uid,
                'senderName': username,
                'senderProfilePic': profImage,
                'postId': postId,
                'postImage': postImage,
                'timestamp': DateTime.now(),
              });
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> postComment(
    String postId,
    String text,
    String uid,
    String name,
    String profilePic,
  ) async {
    String res = 'Some error occurred';
    try {
      String commentId = const Uuid().v1();
      Comments comments = Comments(
        postId: postId,
        profilePic: profilePic,
        name: name,
        uid: uid,
        text: text,
        commentId: commentId,
        datePublished: DateTime.now().toString(),
        likes: [],
      );

      _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .set(comments.toJson());
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> likeComment(
    String postId,
    String commentId,
    String uid,
    List likes,
  ) async {
    try {
      if (likes.contains(uid)) {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
              'likes': FieldValue.arrayRemove([uid]),
            });
      } else {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
              'likes': FieldValue.arrayUnion([uid]),
            });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  //deleting the post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      List following = (snap.data()! as dynamic)['following'];

      // Get current user info for the notification receipt
      String username = (snap.data()! as dynamic)['username'];
      String profilePic = (snap.data()! as dynamic)['photoUrl'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid]),
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId]),
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid]),
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId]),
        });

        // --- ADD NOTIFICATION LOGIC HERE ---
        await _firestore
            .collection('users')
            .doc(followId)
            .collection('notifications')
            .add({
              'isSeen': false,
              'type': 'follow',
              'senderId': uid,
              'senderName': username,
              'senderProfilePic': profilePic,
              'timestamp': DateTime.now(),
            });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> savePost(String postId, String uid, List saved) async {
    try {
      if (saved.contains(postId)) {
        // If already saved, remove it
        await _firestore.collection('users').doc(uid).update({
          'saved': FieldValue.arrayRemove([postId]),
        });
      } else {
        // If not saved, add it
        await _firestore.collection('users').doc(uid).update({
          'saved': FieldValue.arrayUnion([postId]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> sendMessage({
  required String receiverId,
  required String text,
  required String senderId,
  required String senderName,
  required String senderPic,
}) async {
  try {
    if (text.isNotEmpty) {
      List<String> ids = [senderId, receiverId];
      ids.sort(); // Sorting ensures the ID is the same for both users
      String chatId = ids.join("_");

      String messageId = const Uuid().v1();

      // 2. Add message to the 'messages' sub-collection
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .set({
        'senderId': senderId,
        'senderName': senderName,
        'senderPic': senderPic,
        'receiverId': receiverId,
        'text': text,
        'messageId': messageId,
        'timestamp': DateTime.now(),
        'isSeen': false,
      });

      // 3. Update the main 'chat' document with "Last Message" info
      // This is what makes the Chat List look professional later!
      await _firestore.collection('chats').doc(chatId).set({
        'lastMessage': text,
        'lastMessageTime': DateTime.now(),
        'users': ids,
      }, SetOptions(merge: true));
    }
  } catch (e) {
    print(e.toString());
  }
}
}
