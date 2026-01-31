import 'package:flutter/material.dart';
import '../models/chat_mode.dart';
import '../theme/app_theme.dart';

/// Mode selector widget with 4 mode buttons
class ModeSelector extends StatelessWidget {
  final ChatMode currentMode;
  final ValueChanged<ChatMode> onModeChanged;

  const ModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ChatMode.values.map((mode) {
            final isSelected = mode == currentMode;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _ModeButton(
                mode: mode,
                isSelected: isSelected,
                onTap: () => onModeChanged(mode),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final ChatMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: isSelected
            ? AppTheme.primaryColor
            : AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(mode.icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  mode.displayName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
