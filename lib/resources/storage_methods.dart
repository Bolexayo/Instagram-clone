import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StorageMethods {
  Future<String> uploadImageToStorage(
    String childName,
    Uint8List file,
    bool isPost,
  ) async {
    // 1. YOUR SPECIFIC CLOUDINARY DETAILS
    String cloudName = "dpqioocn1";

    String uploadPreset = isPost ? "posts_preset" : "profile_pics_preset";

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');

    var request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes('file', file, filename: '$childName.jpg'),
      );

    // 3. SEND AND RECEIVE
    try {
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      var jsonMap = jsonDecode(responseString);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonMap['secure_url'];
      } else {
        // This will print the actual error from Cloudinary in your console
        debugPrint("Cloudinary Error: $responseString");
        throw Exception("Upload failed with status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("DEBUG ERROR TYPE: ${e.runtimeType}");
      debugPrint("DEBUG ERROR MESSAGE: $e");
      throw e;
    }
  }
}
