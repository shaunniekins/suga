import 'dart:js_interop';

import 'package:suga/services/microphone_permission.dart';
import 'package:web/web.dart' as web;

/// Browsers have no page that can be opened for this; the user unblocks the
/// microphone from the address bar's site settings.
const canOpenMicrophoneSettings = false;

/// Asks the browser for the microphone, releasing it straight away. The
/// browser remembers the answer for this site, so the visualizer can open
/// it again without a second prompt.
Future<MicrophoneAccess> requestMicrophoneAccess() async {
  // Browsers only expose the microphone to HTTPS pages (and localhost).
  if (!web.window.isSecureContext) return MicrophoneAccess.unavailable;

  try {
    final stream = await web.window.navigator.mediaDevices
        .getUserMedia(web.MediaStreamConstraints(audio: true.toJS))
        .toDart;
    for (final track in stream.getTracks().toDart) {
      track.stop();
    }
    return MicrophoneAccess.granted;
  } catch (error) {
    // The error is a DOMException; its name says why.
    final reason = '$error';
    if (reason.contains('NotFoundError') ||
        reason.contains('OverconstrainedError') ||
        reason.contains('NotReadableError')) {
      return MicrophoneAccess.unavailable;
    }
    if (reason.contains('NotAllowedError') ||
        reason.contains('SecurityError')) {
      return MicrophoneAccess.blocked;
    }
    return MicrophoneAccess.denied;
  }
}

Future<bool> openMicrophoneSettings() async => false;
