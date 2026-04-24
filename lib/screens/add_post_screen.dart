import 'dart:typed_data';
import 'package:feather_icons/feather_icons.dart'; // Using your Feather icons
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  // Helper to pick image without the SimpleDialog popup
  void _pickImage(ImageSource source) async {
    Uint8List file = await pickImage(source);
    setState(() {
      _file = file;
    });
  }

  void postImage(String uid, String username, String profImage) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String res = await FirestoreMethods().uploadPost(
        _descriptionController.text,
        _file!,
        uid,
        username,
        profImage,
      );

      if (res == 'success') {
        setState(() {
          _isLoading = false;
        });
        showSnackBar('Posted!', context);
        clearImage();
      } else {
        showSnackBar(res, context);
      }
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
      _descriptionController.clear();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;

    // IF NO IMAGE SELECTED: Show the "Studio" UI
    if (_file == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          title: const Text(
            'New Post',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            // Preview Area
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                width: double.infinity,
                color: const Color.fromARGB(255, 38, 38, 38),
                child: const Center(
                  child: Icon(FeatherIcons.image, size: 60, color: Colors.grey),
                ),
              ),
            ),
            const Spacer(),
            // Large Selection Buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOption(
                    FeatherIcons.camera,
                    "Camera",
                    () => _pickImage(ImageSource.camera),
                  ),
                  _buildOption(
                    FeatherIcons.image,
                    "Gallery",
                    () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // IF IMAGE SELECTED: Show the Caption/Post UI
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        leading: IconButton(
          onPressed: clearImage,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Add Post'),
        actions: [
          TextButton(
            onPressed: () => postImage(user!.uid, user.username, user.photoUrl),
            child: const Text(
              'Post',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _isLoading
              ? const LinearProgressIndicator()
              : const SizedBox(height: 0),
          const Divider(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(backgroundImage: NetworkImage(user!.photoUrl)),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Write a caption...',
                    border: InputBorder.none,
                  ),
                  maxLines: 8,
                ),
              ),
              SizedBox(
                width: 45,
                height: 45,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: MemoryImage(_file!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget for the circular Camera/Gallery buttons
  Widget _buildOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: const Color.fromARGB(255, 38, 38, 38),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
