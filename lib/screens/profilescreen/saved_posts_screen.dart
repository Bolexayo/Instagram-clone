import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/post_detail_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/post_card_skeleton.dart';

class SavedPostsScreen extends StatelessWidget {
  const SavedPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('Saved Posts'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(child: Text('Error loading saved data'));
          }

          // Get the list of saved post IDs from the user document
          List savedPostIds = snapshot.data!.data()!['saved'] ?? [];

          if (savedPostIds.isEmpty) {
            return const Center(child: Text('No saved posts yet'));
          }

          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .where('postId', whereIn: savedPostIds)
                .snapshots(),
            builder: (context, postSnapshot) {
              if (postSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!postSnapshot.hasData || postSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No posts found'));
              }

              return GridView.builder(
                itemCount: postSnapshot.data!.docs.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 1.5,
                  mainAxisSpacing: 1.5,
                ),
                itemBuilder: (context, index) {
                  // FIX: Use postSnapshot here, not snapshot!
                  DocumentSnapshot snap = postSnapshot.data!.docs[index];

                  return InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            PostDetailScreen(postId: snap['postId']),
                      ),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: snap['postUrl'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const PostCardSkeleton(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
