import 'package:flutter/material.dart';
import 'package:instagram_clone/widgets/skeleton_box.dart';
import 'package:shimmer/shimmer.dart';

class ActivitySkeleton extends StatelessWidget {
  const ActivitySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(255, 38, 38, 38),
      highlightColor: const Color.fromARGB(255, 50, 50, 50),
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => ListTile(
          leading: const CircleAvatar(backgroundColor: Colors.white),
          title: const SkeletonBox(height: 12, width: 150),
          subtitle: const SkeletonBox(height: 10, width: 100),
        ),
      ),
    );
  }
}
