import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/activity_screen.dart';
import 'package:instagram_clone/screens/add_post_screen.dart';
import 'package:instagram_clone/screens/feed%20screen/feed_screen.dart';
import 'package:instagram_clone/screens/profilescreen/profile_screen.dart';
import 'package:instagram_clone/screens/search_screen.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  FeedScreen(),
  SearchScreen(),
  AddPostScreen(),
  ActivityScreen(),
  ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid),
];
