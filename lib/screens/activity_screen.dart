import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/screens/profilescreen/profile_screen.dart';
import 'package:instagram_clone/screens/post_detail_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/activity_skeleton.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  void initState() {
    super.initState();
    markAllAsSeen();
  }

  void markAllAsSeen() async {
    try {
      var query = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('notifications')
          .where('isSeen', isEqualTo: false)
          .get();

      for (var doc in query.docs) {
        await doc.reference.update({'isSeen': true});
      }
    } catch (e) {
      debugPrint("No unseen notifications found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text(
          'Activity',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          await Future.delayed(const Duration(seconds: 1));
        },
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('notifications')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ActivitySkeleton();
              }
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No activity yet"));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var data = snapshot.data!.docs[index];

                return ListTile(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfileScreen(uid: data['senderId']),
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(data['senderProfilePic']),
                  ),
                  title: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${data['senderName']} ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: data['type'] == 'follow'
                              ? 'started following you.'
                              : 'liked your post.',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  // POST THUMBNAIL: Shows on the right for likes
                  trailing: data['type'] == 'like'
                      ? GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    PostDetailScreen(postId: data['postId']),
                              ),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: data['postImage'],
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        )
                      : null,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
