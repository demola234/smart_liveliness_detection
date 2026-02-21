import 'package:flutter/material.dart';

import '../painters/liveness_ui_style.dart';
import 'futuristic_liveness_bar.dart';

/// A bottom-sheet widget that lets users choose a [LivenessUiStyle].
///
/// Typical usage — open as a modal bottom sheet and await the result:
///
/// ```dart
/// final chosen = await LivenessStylePicker.show(context, currentStyle);
/// if (chosen != null) setState(() => _style = chosen);
/// ```
class LivenessStylePicker extends StatefulWidget {
  final LivenessUiStyle selected;
  final ValueChanged<LivenessUiStyle> onSelected;

  const LivenessStylePicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  /// Shows the picker as a modal bottom sheet.
  ///
  /// Returns the newly selected [LivenessUiStyle], or `null` if dismissed.
  static Future<LivenessUiStyle?> show(
    BuildContext context,
    LivenessUiStyle current,
  ) {
    return showModalBottomSheet<LivenessUiStyle>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LivenessStylePicker(
        selected: current,
        onSelected: (s) => Navigator.of(context).pop(s),
      ),
    );
  }

  @override
  State<LivenessStylePicker> createState() => _LivenessStylePickerState();
}

class _LivenessStylePickerState extends State<LivenessStylePicker> {
  late LivenessUiStyle _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  void _select(LivenessUiStyle style) {
    setState(() => _selected = style);
    widget.onSelected(style);
  }

  @override
  Widget build(BuildContext context) {
    const styles = LivenessUiStyle.values;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Drag handle ─────────────────────────────────────────────────
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Title ────────────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Text(
              'Choose your experience',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              'Swipe to explore all styles',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),

          // ── Style cards (horizontal scroll) ─────────────────────────────
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: styles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final style = styles[i];
                final isSelected = style == _selected;
                return _StyleCard(
                  style: style,
                  isSelected: isSelected,
                  onTap: () => _select(style),
                );
              },
            ),
          ),

          SizedBox(height: 16 + bottomPad),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StyleCard extends StatelessWidget {
  final LivenessUiStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  const _StyleCard({
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = style.theme;
    final accent = theme.accentColor;
    final isLight = style.isLightBackground;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 148,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accent : Colors.white12,
            width: isSelected ? 2.0 : 1.0,
          ),
          color: isSelected
              ? accent.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.04),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.25),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Animated preview ────────────────────────────────────────
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: SizedBox(
                height: 108,
                child: FuturisticBarPreview(
                  style: style,
                  height: 108,
                ),
              ),
            ),

            // ── Info ────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name row
                    Row(
                      children: [
                        Text(
                          style.icon,
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            style.displayName,
                            style: TextStyle(
                              color: isSelected ? accent : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle,
                              color: accent, size: 14),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Description
                    Expanded(
                      child: Text(
                        style.description,
                        style: TextStyle(
                          color: isLight ? Colors.black54 : Colors.white38,
                          fontSize: 10,
                          height: 1.3,
                        ),
                        overflow: TextOverflow.fade,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
