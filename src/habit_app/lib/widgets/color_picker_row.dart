import 'package:flutter/material.dart';

const List<Color> habitPalette = [
  Color(0xFF3F51B5), // indigo
  Color(0xFF009688), // teal
  Color(0xFF4CAF50), // green
  Color(0xFFFF9800), // orange
  Color(0xFFE91E63), // pink
  Color(0xFF9C27B0), // purple
];

class ColorPickerRow extends StatelessWidget {
  const ColorPickerRow({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final color in habitPalette)
          GestureDetector(
            onTap: () => onSelected(color.toARGB32()),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.toARGB32() == selected
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              child: color.toARGB32() == selected
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          ),
      ],
    );
  }
}
