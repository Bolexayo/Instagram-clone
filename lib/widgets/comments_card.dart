import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/profilescreen/profile_screen.dart';
import 'package:instagram_clone/utils/helper_functions.dart';
import 'package:instagram_clone/widgets/like_animation.dart';
import 'package:provider/provider.dart';

class CommentsCard extends StatefulWidget {
  final Map<String, dynamic> snap;
  const CommentsCard({super.key, required this.snap});

  @override
  State<CommentsCard> createState() => _CommentsCardState();
}

class _CommentsCardState extends State<CommentsCard> {
  @override
  Widget build(BuildContext context) {
    Text(
      formatTimestamp(widget.snap['datePublished']), // Pass the String directly
      style: const TextStyle(color: Colors.grey, fontSize: 12),
    );
    final User? user = Provider.of<UserProvider>(context).getUser;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProfileScreen(uid: widget.snap['uid']),
              ),
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(widget.snap['profilePic']),
              radius: 18,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfileScreen(uid: widget.snap['uid']),
                      ),
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: widget.snap['name'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: formatTimestamp(
                              widget.snap['datePublished'],
                              isComment: true, // Use the short format
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      children: [TextSpan(text: widget.snap['text'])],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LikeAnimation(
                isAnimating: widget.snap['likes'].contains(user?.uid),
                smallLike: true,
                child: GestureDetector(
                  onTap: () async {
                    await FirestoreMethods().likeComment(
                      widget.snap['postId'],
                      widget.snap['commentId'],
                      user!.uid,
                      widget.snap['likes'],
                    );
                  },
                  child: widget.snap['likes'].contains(user?.uid)
                      ? const Icon(Icons.favorite, color: Colors.red, size: 15)
                      : const Icon(FeatherIcons.heart, size: 15),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.snap['likes'].length}',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
