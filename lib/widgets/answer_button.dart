import 'package:flutter/material.dart';

class AnswerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool? isCorrect;
  final bool selected;
  final bool revealAsCorrect;

  const AnswerButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isCorrect,
    this.selected = false,
    this.revealAsCorrect = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color? background;
    Color? foreground;

    if (isCorrect != null) {
      if (revealAsCorrect || (selected && isCorrect == true)) {
        background = Colors.green.shade700;
        foreground = Colors.white;
      } else if (selected && isCorrect == false) {
        background = scheme.error;
        foreground = scheme.onError;
      }
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(58),
          backgroundColor: background,
          foregroundColor: foreground,
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}
