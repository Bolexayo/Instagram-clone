import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/post_card.dart';

class PostDetailScreen extends StatelessWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('Post'),
        centerTitle: false,
      ),
      body: StreamBuilder(
        // Listen to just THIS specific post
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(child: Text("Post no longer exists"));
          }

          return ListView(
            children: [
              PostCard(
                snap: snapshot.data!.data() as Map<String, dynamic>,
              ),
            ],
          );
        },
      ),
    );
  }
}
