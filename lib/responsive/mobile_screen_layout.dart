import 'dart:async'; // Required for StreamSubscription
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_variables.dart';
import 'package:instagram_clone/utils/utils.dart'; // For showSnackBar
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
  late PageController pageController;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    addData();

    // GLOBAL OFFLINE LISTENER
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      final bool currentlyOffline = result.contains(ConnectivityResult.none);

      if (currentlyOffline && !_isOffline) {
        showSnackBar("You are offline. Showing cached data.", context);
      }

      setState(() {
        _isOffline = currentlyOffline;
      });
    });
  }

  addData() async {
    UserProvider userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    await userProvider.refreshUser();
  }

  @override
  void dispose() {
    pageController.dispose();
    _connectivitySubscription.cancel(); // CLEAN UP: Prevents memory leaks
    super.dispose();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).getUser;
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

    if (user == null) {
      return PopScope(
        canPop: false, // Prevent immediate exit
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) return;

          if (_page != 0) {
            // If not on Feed, go to Feed
            navigationTapped(0);
          } else {
            // If on Feed, actually exit the app
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          }
        },
        child: const Scaffold(
          body: Center(child: CircularProgressIndicator(color: primaryColor)),
        ),
      );
    }

    return PopScope(
      canPop: false, // Prevent immediate exit
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;

        if (_page != 0) {
          // If not on Feed, go to Feed
          navigationTapped(0);
        } else {
          // If on Feed, actually exit the app
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
      },
      child: Scaffold(
        // OFFLINE INDICATOR: Shows a tiny red bar at the top if internet is lost
        appBar: _isOffline
            ? PreferredSize(
                preferredSize: const Size.fromHeight(20),
                child: Container(
                  color: Colors.redAccent,
                  alignment: Alignment.center,
                  child: const Text(
                    "No Internet Connection",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : null,
        body: PageView(
          controller: pageController,
          onPageChanged: onPageChanged,
          children: homeScreenItems,
        ),
        bottomNavigationBar: CupertinoTabBar(
          backgroundColor: mobileBackgroundColor,
          onTap: navigationTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                FeatherIcons.home,
                color: _page == 0 ? primaryColor : secondaryColor,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                FeatherIcons.search,
                color: _page == 1 ? primaryColor : secondaryColor,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                FeatherIcons.plusSquare,
                color: _page == 2 ? primaryColor : secondaryColor,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: currentUid.isEmpty
                  ? const Icon(FeatherIcons.heart)
                  : StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUid)
                          .collection('notifications')
                          .where('isSeen', isEqualTo: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        bool hasUnseen =
                            snapshot.hasData && snapshot.data!.docs.isNotEmpty;
                        return Badge(
                          isLabelVisible: hasUnseen,
                          smallSize: 8,
                          backgroundColor: Colors.red,
                          child: Icon(
                            FeatherIcons.heart,
                            color: _page == 3 ? primaryColor : secondaryColor,
                          ),
                        );
                      },
                    ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _page == 4 ? primaryColor : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 11,
                  backgroundImage: NetworkImage(user.photoUrl),
                ),
              ),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
