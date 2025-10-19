import 'package:flutter/material.dart';

import '../../../theme/insets.dart';

/// Individual folder tab widget
class FolderTab extends StatelessWidget {
  /// Creates an instance of the [FolderTab] widget.
  const FolderTab({
    required this.text,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
    super.key,
  });

  /// The text to display in the tab.
  final String text;

  /// Determines if the tab is selected.
  final bool isSelected;

  /// A callback for taps on the tab.
  final VoidCallback onTap;

  /// Color for the selected tab.
  final Color selectedColor;

  /// Color for the unselected tab.
  final Color unselectedColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, // Take full available width
        padding: const EdgeInsets.symmetric(
          horizontal: Insets.medium,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center, // Center the text
          style: const TextStyle(
            color: Color(0xFF212121),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
