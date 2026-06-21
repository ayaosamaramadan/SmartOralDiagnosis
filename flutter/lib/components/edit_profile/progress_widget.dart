import 'package:flutter/material.dart';

class ProgressWidget extends StatelessWidget {
  final int percent;
  final double size;

  const ProgressWidget({super.key, required this.percent, this.size = 96});

  @override
  Widget build(BuildContext context) {
    final value = (percent.clamp(0, 100)) / 100.0;
    final theme = Theme.of(context);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 8,
              backgroundColor: theme.colorScheme.onSurface.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
            ),
          ),
          Text(
            '$percent%',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
          )
        ],
      ),
    );
  }
}
