import 'package:flutter/material.dart';

const List<Color> habitPalette = [
  Color(0xFFE0A33A), // amber
  Color(0xFF4F8CFF), // blue
  Color(0xFFE05050), // red
  Color(0xFF26C281), // green
  Color(0xFF21B5A1), // teal
  Color(0xFFE2733A), // orange
  Color(0xFFE0518F), // pink
  Color(0xFF8C5BE0), // purple
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.toARGB32() == selected
                      ? Colors.white
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
