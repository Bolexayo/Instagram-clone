import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/feed%20screen/chat_screen.dart';
import 'package:instagram_clone/screens/post_detail_screen.dart';
import 'package:instagram_clone/screens/profilescreen/follower_screen.dart';
import 'package:instagram_clone/screens/profilescreen/following_screen.dart';
import 'package:instagram_clone/screens/profilescreen/settings_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/follow_button.dart';
import 'package:instagram_clone/widgets/post_card_skeleton.dart';
import 'package:instagram_clone/widgets/profile_skeleton.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postsLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    if (isLoading) {
      return const ProfileSkeleton();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(
          userData['username'] ?? "",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => SettingsScreen())),
            icon: const Icon(FeatherIcons.menu),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          await Future.delayed(const Duration(seconds: 1));
        },
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ProfileSkeleton();
            }
            if (!snapshot.hasData || snapshot.data!.data() == null) {
              return const Center(child: Text("User does not exist"));
            }

            // Get live data from the stream
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            int followers = userData['followers'].length;
            int following = userData['following'].length;
            bool isFollowing = userData['followers'].contains(
              FirebaseAuth.instance.currentUser!.uid,
            );

            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(userData['photoUrl']),
                            radius: 40,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Stream for Post Count
                                    StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('posts')
                                          .where('uid', isEqualTo: widget.uid)
                                          .snapshots(),
                                      builder: (context, postSnapshot) {
                                        int pLen = postSnapshot.hasData
                                            ? postSnapshot.data!.docs.length
                                            : 0;
                                        return buildStatColumn(pLen, "posts");
                                      },
                                    ),
                                    InkWell(
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FollowerScreen(uid: widget.uid),
                                        ),
                                      ),
                                      child: buildStatColumn(
                                        followers,
                                        "followers",
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FollowingScreen(uid: widget.uid),
                                        ),
                                      ),
                                      child: buildStatColumn(
                                        following,
                                        "following",
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    FirebaseAuth.instance.currentUser!.uid ==
                                            widget.uid
                                        ? FollowButton(
                                            width: textScaler.scale(250),
                                            text: 'Edit Profile',
                                            backgroundColor:
                                                mobileBackgroundColor,
                                            textColor: primaryColor,
                                            borderColor: Colors.grey,
                                            function: () {},
                                          )
                                        : isFollowing
                                        ? FollowButton(
                                            width: textScaler.scale(130),
                                            text: 'Unfollow',
                                            backgroundColor: Colors.white,
                                            textColor: Colors.black,
                                            borderColor: Colors.grey,
                                            function: () async {
                                              await FirestoreMethods()
                                                  .followUser(
                                                    FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid,
                                                    userData['uid'],
                                                  );
                                            },
                                          )
                                        : FollowButton(
                                            width: 250,
                                            text: 'Follow',
                                            backgroundColor: blueColor,
                                            textColor: Colors.white,
                                            borderColor: Colors.blue,
                                            function: () async {
                                              await FirestoreMethods()
                                                  .followUser(
                                                    FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid,
                                                    userData['uid'],
                                                  );
                                            },
                                          ),
                                    Expanded(
                                      child: FollowButton(
                                        width: 130,
                                        text: 'Message',
                                        backgroundColor: mobileBackgroundColor,
                                        textColor: primaryColor,
                                        borderColor: Colors.grey,
                                        function: () =>
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChatScreen(
                                                      receiverId:
                                                          userData['uid'],
                                                      receiverName:
                                                          userData['username'],
                                                      receiverPic:
                                                          userData['photoUrl'],
                                                    ),
                                              ),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          userData['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(userData['bio']),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // StreamBuilder for the Post Grid
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .where('uid', isEqualTo: widget.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const ProfileSkeleton();
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(), // Disable internal scrolling
                      itemCount: snapshot.data!.docs.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 1.5,
                            mainAxisSpacing: 1.5,
                            childAspectRatio: 1.0, // Standard IG square
                          ),
                      itemBuilder: (context, index) {
                        DocumentSnapshot snap = snapshot.data!.docs[index];
                        return InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PostDetailScreen(
                                postId:
                                    snap['postId'], // Pass the ID from the snapshot
                              ),
                            ),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: snap['postUrl'],
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const PostCardSkeleton(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          overflow: TextOverflow.clip,
          num.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 3),
          child: Text(
            overflow: TextOverflow.clip,
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
