import 'package:flutter/material.dart';

import '../utils/palette.dart';

class IconPicker extends StatelessWidget {
  const IconPicker({
    super.key,
    required this.selectedCodePoint,
    required this.onSelect,
  });

  final int selectedCodePoint;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: habitIcons.map((icon) {
        final selected = icon.codePoint == selectedCodePoint;
        return GestureDetector(
          onTap: () => onSelect(icon.codePoint),
          child: Container(
            decoration: BoxDecoration(
              color: selected
                  ? Colors.white.withValues(alpha: 0.12)
                  : const Color(0xFF252525),
              borderRadius: BorderRadius.circular(10),
              border: selected
                  ? Border.all(color: Colors.white, width: 1.5)
                  : null,
            ),
            child: Icon(icon, size: 22),
          ),
        );
      }).toList(),
    );
  }
}
