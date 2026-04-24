import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/post_detail_screen.dart';
import 'package:instagram_clone/screens/profilescreen/profile_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/search_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowusers = false;

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: SearchBarWidget(
          onChanged: (String value) {
            setState(() {
              isShowusers = value.isNotEmpty;
            });
          },
          controller: searchController,
          onSearch: (String value) {
            if (value.isNotEmpty) {
              setState(() {
                isShowusers = true;
              });
            }
          },
        ),
      ),
      body: isShowusers
          ? StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where(
                    'username',
                    isGreaterThanOrEqualTo: searchController.text,
                  )
                  .where('username', isLessThanOrEqualTo: searchController.text + '\uf8ff')
                  .snapshots(),
              builder: (context, snapshot) {
                // 1. IMPROVED GUARD: Check for errors and waiting states
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. SAFETY CHECK: Ensure data is not null and actually exists
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text("No users found"));
                }

                // Use a local variable to avoid calling (snapshot.data! as dynamic) repeatedly
                final docs = (snapshot.data! as dynamic).docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data();

                    return InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(uid: data['uid']),
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(data['photoUrl'] ?? ""),
                        ),
                        title: Text(data['username'] ?? "Unknown"),
                      ),
                    );
                  },
                );
              },
            )
          : FutureBuilder(
              future: FirebaseFirestore.instance.collection('posts').get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return GridView.builder(
                  shrinkWrap: true,
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 images per row
                    crossAxisSpacing: .5, // Tiny gap like real IG
                    mainAxisSpacing: .5,
                    childAspectRatio: .8, // Perfectly square
                  ),
                  itemBuilder: (context, index) {
                    DocumentSnapshot snap =
                        (snapshot.data! as dynamic).docs[index];

                    return InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              PostDetailScreen(postId: snap['postId']),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(2),
                        child: Image.network( 
                          snap['postUrl'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
