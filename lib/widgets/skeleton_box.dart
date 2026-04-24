import 'package:flutter/material.dart';

class SkeletonBox extends StatelessWidget {
  final double height;
  final double width;
  const SkeletonBox({super.key, required this.height, this.width = double.infinity});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
