import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final Function(String) onChanged;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38, // Slimmer height like real IG
      decoration: BoxDecoration(
        color: const Color.fromARGB(
          255,
          38,
          38,
          38,
        ), // Subtle dark gray contrast
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextFormField(
        controller: controller,
        onChanged: onSearch,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        textAlignVertical: TextAlignVertical.center,
        decoration: const InputDecoration(
          hintText: 'Search for a user',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
          prefixIcon: Icon(FeatherIcons.search, color: Colors.grey, size: 18),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.only(bottom: 10), // Keeps hint centered
        ),
      ),
    );
  }
}
