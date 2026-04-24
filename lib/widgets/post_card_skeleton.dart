import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[800]!, // Darker for your black theme
        highlightColor: Colors.grey[700]!,
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(backgroundColor: Colors.white),
              title: Container(height: 10, width: 10, color: Colors.white),
            ),
            Container(height: 250, width: double.infinity, color: Colors.white),
            // Add more shapes to match your PostCard
          ],
        ),
      ),
    );
  }
}
