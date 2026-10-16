import 'package:flutter/material.dart';
import 'package:suga/app/theme.dart';
import 'package:suga/models/mode_lineup.dart';

/// Shows the sheet for choosing and ordering modes. Every change is passed
/// to [onChanged] straight away, so the switcher behind updates live.
Future<void> showModeLineupSheet(
  BuildContext context, {
  required ModeLineup lineup,
  required ValueChanged<ModeLineup> onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: SugaColors.slate,
    barrierColor: Colors.black38,
    builder: (_) => _ModeLineupSheet(lineup: lineup, onChanged: onChanged),
  );
}

class _ModeLineupSheet extends StatefulWidget {
  const _ModeLineupSheet({required this.lineup, required this.onChanged});

  final ModeLineup lineup;
  final ValueChanged<ModeLineup> onChanged;

  @override
  State<_ModeLineupSheet> createState() => _ModeLineupSheetState();
}

class _ModeLineupSheetState extends State<_ModeLineupSheet> {
  late ModeLineup _lineup = widget.lineup;

  void _update(ModeLineup lineup) {
    if (lineup == _lineup) return;
    setState(() => _lineup = lineup);
    widget.onChanged(lineup);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final isDefault = _lineup == ModeLineup();

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Modes',
                    style: text.titleLarge?.copyWith(color: SugaColors.ice),
                  ),
                ),
                TextButton(
                  onPressed: isDefault ? null : () => _update(ModeLineup()),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              'Drag to change the order. Switch off the modes you '
              "don't want.",
              style: text.bodyMedium?.copyWith(color: SugaColors.mist),
            ),
          ),
          Flexible(
            child: ReorderableListView.builder(
              shrinkWrap: true,
              buildDefaultDragHandles: false,
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: _lineup.order.length,
              onReorder: (from, to) => _update(_lineup.moved(from, to)),
              proxyDecorator: (child, _, _) =>
                  Material(color: SugaColors.night, elevation: 6, child: child),
              itemBuilder: (context, index) {
                final mode = _lineup.order[index];
                final on = _lineup.isEnabled(mode);
                final locked = on && !_lineup.canHide(mode);

                return ListTile(
                  key: ValueKey(mode),
                  contentPadding: const EdgeInsets.only(left: 24, right: 8),
                  leading: Icon(
                    mode.icon,
                    color: on ? SugaColors.ice : SugaColors.mist,
                  ),
                  title: Text(
                    mode.label,
                    style: TextStyle(
                      color: on ? SugaColors.ice : SugaColors.mist,
                    ),
                  ),
                  subtitle: locked
                      ? const Text(
                          'Keep at least one mode on',
                          style: TextStyle(color: SugaColors.mist),
                        )
                      : null,
                  onTap: locked ? null : () => _update(_lineup.toggled(mode)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: on,
                        onChanged: locked
                            ? null
                            : (_) => _update(_lineup.toggled(mode)),
                      ),
                      ReorderableDragStartListener(
                        index: index,
                        child: Tooltip(
                          message: 'Drag to reorder ${mode.label}',
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.drag_handle_rounded,
                              color: SugaColors.mist,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
