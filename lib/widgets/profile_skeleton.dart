import 'package:flutter/material.dart';
import 'package:instagram_clone/widgets/skeleton_box.dart';
import 'package:shimmer/shimmer.dart';

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(255, 38, 38, 38),
      highlightColor: const Color.fromARGB(255, 50, 50, 50),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(radius: 40, backgroundColor: Colors.white),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        3,
                        (i) => const SkeletonBox(height: 30, width: 50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            const SkeletonBox(height: 200),
          ],
        ),
      ),
    );
  }
}
