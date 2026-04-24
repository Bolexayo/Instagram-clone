import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/screens/feed%20screen/chat_list_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_variables.dart';
import 'package:instagram_clone/widgets/post_card.dart';
import 'package:instagram_clone/widgets/post_card_skeleton.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      if (result.contains(ConnectivityResult.none)) {
        Banner(message: 'You are offline', location: BannerLocation.topStart);
      }
    });
    final user = Provider.of<UserProvider>(context, listen: false).getUser;
    final width = MediaQuery.of(context).size.width;
    if (user == null) {
      return const SizedBox();
    }
    return Scaffold(
      backgroundColor: width > webScreenSize
          ? webBackgroundColor
          : mobileBackgroundColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: mobileBackgroundColor,
              centerTitle: false,
              title: SvgPicture.asset(
                'assets/ic_instagram.svg',
                colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
                height: 32,
              ),
              actions: [
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ChatListScreen()),
                  ),
                  icon: Icon(FeatherIcons.send),
                ),
              ],
            ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          await Future.delayed(const Duration(seconds: 1));
        },
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('posts').snapshots(),
          builder:
              (
                context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
              ) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => PostCardSkeleton(),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) => Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: width > webScreenSize ? width * 0.3 : 0,
                      vertical: width > webScreenSize ? 10 : 0,
                    ),
                    child: PostCard(snap: snapshot.data!.docs[index].data()),
                  ),
                );
              },
        ),
      ),
    );
  }
}
