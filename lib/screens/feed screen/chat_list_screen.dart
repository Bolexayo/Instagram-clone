import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/screens/feed%20screen/chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index];

              if (data['uid'] == FirebaseAuth.instance.currentUser!.uid){ return const SizedBox();}
               

              return ListTile(
                onTap: () {
                  // NAVIGATE: Pass the receiver's details to the ChatScreen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        receiverId: data['uid'],
                        receiverName: data['username'],
                        receiverPic: data['photoUrl'],
                      ),
                    ),
                  );
                },
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(data['photoUrl']),
                ),
                title: Text(data['username']),
                subtitle: const Text('Tap to chat'),
              );
            },
          );
        },
      ),
    );
  }
}
