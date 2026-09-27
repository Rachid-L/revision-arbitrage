import 'package:flutter/material.dart';

class AnswerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool selected;
  final bool? isCorrect;
  final bool revealAsCorrect;

  const AnswerButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.selected = false,
    this.isCorrect,
    this.revealAsCorrect = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color? background;
    Color? foreground;
    Color border = scheme.outlineVariant;
    IconData? icon;

    if (revealAsCorrect) {
      background = Colors.green.withValues(alpha: .14);
      foreground = Colors.green.shade700;
      border = Colors.green.shade500;
      icon = Icons.check_circle_rounded;
    } else if (selected && isCorrect == false) {
      background = scheme.errorContainer;
      foreground = scheme.onErrorContainer;
      border = scheme.error;
      icon = Icons.cancel_rounded;
    } else if (selected) {
      background = scheme.primaryContainer;
      foreground = scheme.onPrimaryContainer;
      border = scheme.primary;
    }

    return SizedBox(
      height: 62,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          side: BorderSide(color: border, width: selected || revealAsCorrect ? 2 : 1),
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.left,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            if (icon != null) Icon(icon),
          ],
        ),
      ),
    );
  }
}
