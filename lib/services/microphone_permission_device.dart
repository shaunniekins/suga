import 'package:permission_handler/permission_handler.dart';
import 'package:suga/services/microphone_permission.dart';

/// Whether [openMicrophoneSettings] can take the user to a place to unblock
/// the microphone.
const canOpenMicrophoneSettings = true;

/// Asks for microphone access, or returns the current answer if the user
/// has already decided.
Future<MicrophoneAccess> requestMicrophoneAccess() async {
  final status = await Permission.microphone.request();
  if (status.isGranted || status.isLimited) return MicrophoneAccess.granted;
  if (status.isPermanentlyDenied || status.isRestricted) {
    return MicrophoneAccess.blocked;
  }
  return MicrophoneAccess.denied;
}

Future<bool> openMicrophoneSettings() => openAppSettings();
