/// A music app Suga can open so the user can start a song, then come back
/// to the light show. Suga never plays or controls the music itself: the
/// microphone hears it like any other sound in the room.
///
/// When adding an app, add its Android package to the `<queries>` in
/// `android/app/src/main/AndroidManifest.xml`, or Android reports it as not
/// installed.
enum MusicApp {
  spotify(
    label: 'Spotify',
    iosUri: 'spotify:',
    webUri: 'https://open.spotify.com/',
  ),
  youtubeMusic(
    label: 'YouTube Music',
    iosUri: 'youtubemusic://',
    webUri: 'https://music.youtube.com/',
  ),
  appleMusic(
    label: 'Apple Music',
    iosUri: 'music://',
    webUri: 'https://music.apple.com/',
  );

  const MusicApp({
    required this.label,
    required this.iosUri,
    required this.webUri,
  });

  final String label;

  /// The app's own URL scheme. iOS opens it only when the app is installed.
  final String iosUri;

  /// The app's web address. Android hands it to the installed app (its
  /// verified app link); the web app opens it in a new tab.
  final String webUri;
}
