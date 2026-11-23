import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:suga/models/music_app.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [MusicApp]s; returns whether the app (or, on the web, its tab)
/// opened. Injectable so tests don't leave the app.
typedef MusicLauncher = Future<bool> Function(MusicApp app);

/// Opens [app] if it's installed. On Android and iOS it never falls back to
/// a browser, so a missing app reports `false` instead of opening a web page.
Future<bool> openMusicApp(MusicApp app) async {
  try {
    if (kIsWeb) {
      return await launchUrl(
        Uri.parse(app.webUri),
        webOnlyWindowName: '_blank',
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await launchUrl(
        Uri.parse(app.iosUri),
        mode: LaunchMode.externalApplication,
      );
    }
    return await launchUrl(
      Uri.parse(app.webUri),
      mode: LaunchMode.externalNonBrowserApplication,
    );
  } on Exception catch (error) {
    developer.log('Could not open ${app.label}', name: 'suga', error: error);
    return false;
  }
}
