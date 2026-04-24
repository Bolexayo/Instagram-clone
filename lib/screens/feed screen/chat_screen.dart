import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String receiverPic;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.receiverPic,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).getUser;

    List<String> ids = [user!.uid, widget.receiverId];
    ids.sort();
    String chatId = ids.join("_");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.receiverPic),
            ),
            const SizedBox(width: 10),
            Text(widget.receiverName, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. LIVE MESSAGE LIST
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true) // Newest at bottom
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  reverse: true, // Key for chat: starts from bottom
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index];
                    bool isMe = data['senderId'] == user.uid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 10,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? blueColor
                              : const Color.fromARGB(255, 38, 38, 38),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          data['text'],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 2. INPUT FIELD
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await FirestoreMethods().sendMessage(
                      receiverId: widget.receiverId,
                      text: _messageController.text,
                      senderId: user.uid,
                      senderName: user.username,
                      senderPic: user.photoUrl,
                    );
                    _messageController.clear();
                  },
                  icon: const Icon(Icons.send, color: blueColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
