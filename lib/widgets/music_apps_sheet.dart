import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:suga/app/theme.dart';
import 'package:suga/models/music_app.dart';
import 'package:suga/services/music_launcher.dart';

/// Shows the sheet that opens a music app. If the chosen app isn't
/// installed, a snack bar says so.
Future<void> showMusicAppsSheet(
  BuildContext context, {
  MusicLauncher launch = openMusicApp,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final opening = await showModalBottomSheet<(MusicApp, Future<bool>)>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: SugaColors.slate,
    barrierColor: Colors.black38,
    // Launch inside the tap, before the sheet closes: browsers only open a
    // new tab straight from a user gesture.
    builder: (context) => _MusicAppsSheet(
      onOpen: (app) => Navigator.of(context).pop((app, launch(app))),
    ),
  );
  if (opening == null) return;

  final (app, opened) = opening;
  if (await opened) return;
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        kIsWeb
            ? "Couldn't open ${app.label}. Your browser may have blocked it."
            : "Couldn't open ${app.label}. Is it installed?",
      ),
    ),
  );
}

class _MusicAppsSheet extends StatelessWidget {
  const _MusicAppsSheet({required this.onOpen});

  final ValueChanged<MusicApp> onOpen;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
          child: Text(
            'Play music',
            style: text.titleLarge?.copyWith(color: SugaColors.ice),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          child: Text(
            kIsWeb
                ? 'Start a song in a new tab, then come back here. Suga '
                      'listens through the microphone, so turn the volume up.'
                : 'Start a song, then come back to Suga. It listens through '
                      'the microphone, so play it out loud, not on headphones.',
            style: text.bodyMedium?.copyWith(color: SugaColors.mist),
          ),
        ),
        for (final app in MusicApp.values)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: const Icon(
              Icons.music_note_rounded,
              color: SugaColors.ice,
            ),
            title: Text(
              app.label,
              style: const TextStyle(color: SugaColors.ice),
            ),
            trailing: const Icon(
              Icons.open_in_new_rounded,
              color: SugaColors.mist,
            ),
            onTap: () => onOpen(app),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}
