import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

Future<bool> requestMediaPermission() async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    
    // Android 13 (SDK 33) and above
    if (androidInfo.version.sdkInt >= 33) {
      PermissionStatus status = await Permission.photos.request();
      
      // Handle Android 14 "Partial Access" (isLimited)
      if (status.isGranted || status.isLimited) {
        return true;
      }
    } else {
      // Android 12 and below
      PermissionStatus status = await Permission.storage.request();
      return status.isGranted;
    }
  }
  return false;
}
