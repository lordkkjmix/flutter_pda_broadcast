import 'package:flutter/material.dart';

/// Widget d'indicateur de statut avec animation
class StatusIndicator extends StatelessWidget {
  final bool isActive;
  final String label;
  final Color? activeColor;
  final Color? inactiveColor;

  const StatusIndicator({
    super.key,
    required this.isActive,
    required this.label,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveActiveColor = activeColor ?? Colors.green;
    final effectiveInactiveColor = inactiveColor ?? Colors.grey;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? effectiveActiveColor : effectiveInactiveColor,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: effectiveActiveColor.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: isActive
              ? Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  margin: const EdgeInsets.all(3),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isActive ? effectiveActiveColor : effectiveInactiveColor,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
