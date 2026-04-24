import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/profilescreen/profile_screen.dart';
import 'package:instagram_clone/utils/colors.dart';

class FollowingScreen extends StatelessWidget {
  final String uid;
  const FollowingScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    String myUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('...');
            return Text(
              snapshot.data!['username'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            );
          },
        ),
        centerTitle: false,
      ),
      backgroundColor: mobileBackgroundColor,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(child: Text('Error loading data'));
          }

          List following = snapshot.data!['following'];

          if (following.isEmpty) {
            return const Center(child: Text('Not following anyone yet'));
          }

          return ListView.builder(
            itemCount: following.length,
            itemBuilder: (context, index) {
              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(following[index])
                    .snapshots(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData || userSnap.data!.data() == null) {
                    return const SizedBox();
                  }

                  var data = userSnap.data!.data() as Map<String, dynamic>;

                  return ListTile(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(uid: data['uid']),
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(data['photoUrl']),
                    ),
                    title: Text(
                      data['username'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      data['bio'] ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: uid == myUid
                        ? IconButton(
                            onPressed: () {
                              // Show the confirmation dialog
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: mobileBackgroundColor,
                                  title: const Text('Unfollow?'),
                                  content: Text(
                                    'Are you sure you want to unfollow ${data['username']}?',
                                  ),
                                  actions: [
                                    // Cancel Button
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    // Confirm Unfollow Button
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(
                                          context,
                                        ); // Close dialog first

                                        // Run the existing logic
                                        await FirestoreMethods().followUser(
                                          myUid,
                                          data['uid'],
                                        );
                                      },
                                      child: const Text(
                                        'Unfollow',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.close, size: 20),
                          )
                        : null,
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
