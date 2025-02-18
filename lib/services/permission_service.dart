// import 'package:permission_handler/permission_handler.dart';

// Future<bool> checkCameraPermission() async {
//   final status = await Permission.camera.status;
//   if (status.isGranted) {
//     return true;
//   }
//   final newStatus = await Permission.camera.request();
//   if (newStatus.isGranted) {
//     return true;
//   } else if (newStatus.isPermanentlyDenied) {
//     openAppSettings();
//   }
//   return false;
// }
import 'package:permission_handler/permission_handler.dart';

Future<bool> checkCameraPermission() async {
  final status = await Permission.camera.status;

  if (status.isGranted) {
    return true;
  }
  if (status.isDenied || status.isRestricted) {
    final newStatus = await Permission.camera.request();
    return newStatus.isGranted;
  }
  if (status.isPermanentlyDenied) {
    await openAppSettings();
    return false;
  }

  return false;
}
