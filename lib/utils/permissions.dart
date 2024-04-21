import 'package:permission_handler/permission_handler.dart';

Future<bool> checkPermission() async => await Permission.microphone.isGranted;

Future<void> requestPermission() async => await Permission.microphone.request();
