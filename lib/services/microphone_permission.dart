export 'package:suga/services/microphone_permission_device.dart'
    if (dart.library.js_interop) 'package:suga/services/microphone_permission_web.dart';

enum MicrophoneAccess {
  granted,

  /// The user said no this time; asking again may work.
  denied,

  /// The user or a policy blocked access; only settings can undo it.
  blocked,

  /// There's no microphone, or the browser won't offer one (e.g. the page
  /// isn't served over HTTPS).
  unavailable,
}
