import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../widgets/color_picker_row.dart';

class EditHabitScreen extends StatefulWidget {
  const EditHabitScreen({super.key, this.habit});

  final Habit? habit;

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  late final TextEditingController _nameController;
  late int _colorValue;

  bool get _isEditing => widget.habit != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit?.name ?? '');
    _colorValue = widget.habit?.colorValue ?? habitPalette.first.toARGB32();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a habit name.')),
      );
      return;
    }

    final provider = context.read<HabitProvider>();
    if (_isEditing) {
      final habit = widget.habit!
        ..name = name
        ..colorValue = _colorValue;
      await provider.updateHabit(habit);
    } else {
      await provider.addHabit(name: name, colorValue: _colorValue);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${widget.habit!.name}"?'),
        content: const Text(
          'This will erase its check-in history. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;

    await context.read<HabitProvider>().deleteHabit(widget.habit!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(_colorValue);
    final surface = Theme.of(context).colorScheme.surfaceContainerHighest;
    final muted = Colors.white.withValues(alpha: 0.6);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Habit' : 'New Habit'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            // Live preview pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: Color.alphaBlend(color.withValues(alpha: 0.2), surface),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: color, radius: 8),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _nameController.text.trim().isEmpty
                          ? 'Your habit name'
                          : _nameController.text.trim(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('NAME', style: _labelStyle(muted)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              maxLength: 40,
              autofocus: !_isEditing,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'e.g. Drink water',
                filled: true,
                fillColor: surface,
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
            ),

            const SizedBox(height: 20),
            Text('COLOR', style: _labelStyle(muted)),
            const SizedBox(height: 12),
            ColorPickerRow(
              selected: _colorValue,
              onSelected: (v) => setState(() => _colorValue = v),
            ),

            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(_isEditing ? 'Save' : 'Create'),
            ),

            if (_isEditing) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _delete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete habit'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  TextStyle _labelStyle(Color color) => TextStyle(
        fontSize: 11,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
        color: color,
      );
}
