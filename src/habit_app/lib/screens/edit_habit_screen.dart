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
        content: const Text('This will erase its check-in history. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit habit' : 'New habit'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nameController,
            maxLength: 40,
            autofocus: !_isEditing,
            decoration: const InputDecoration(
              labelText: 'Habit name',
              hintText: 'e.g. Drink water',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 16),
          Text('Color', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 12),
          ColorPickerRow(
            selected: _colorValue,
            onSelected: (v) => setState(() => _colorValue = v),
          ),
          if (_isEditing) ...[
            const SizedBox(height: 32),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete habit'),
            ),
          ],
        ],
      ),
    );
  }
}
