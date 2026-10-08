import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/habit_options.dart';
import '../../../core/utils/snack.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../models/habit.dart';
import '../../../providers/habit_provider.dart';

class AddEditHabitScreen extends StatefulWidget {
  const AddEditHabitScreen({super.key, this.habit});

  final Habit? habit;

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.habit?.name);
  late final TextEditingController _description =
      TextEditingController(text: widget.habit?.description);
  late int _icon = widget.habit?.iconIndex ?? 0;
  late int _color = widget.habit?.colorIndex ?? 0;
  late final Set<int> _days =
      {...(widget.habit?.weekdays ?? const [1, 2, 3, 4, 5, 6, 7])};
  bool _saving = false;

  bool get _isEdit => widget.habit != null;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_days.isEmpty) {
      showAppSnack(context, 'Select at least one day.', error: true);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final provider = context.read<HabitProvider>();
    final weekdays = _days.toList()..sort();

    try {
      if (_isEdit) {
        await provider.update(widget.habit!.copyWith(
          name: _name.text.trim(),
          description: _description.text.trim(),
          iconIndex: _icon,
          colorIndex: _color,
          weekdays: weekdays,
        ));
      } else {
        await provider.add(Habit(
          id: '',
          name: _name.text.trim(),
          description: _description.text.trim(),
          iconIndex: _icon,
          colorIndex: _color,
          weekdays: weekdays,
          completedDates: const {},
          createdAt: DateTime.now(),
        ));
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        showAppSnack(context, 'Could not save habit. Try again.', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final accent = HabitOptions.colorAt(_color);

    Widget label(String t) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(t,
              style: text.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit habit' : 'New habit'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              AppTextField(
                controller: _name,
                label: 'Name',
                hint: 'e.g. Read for 20 minutes',
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => Validators.required(v, 'Give your habit a name'),
              ),
              const SizedBox(height: 18),
              AppTextField(
                controller: _description,
                label: 'Description (optional)',
                hint: 'Why does this habit matter to you?',
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              label('Repeat on'),
              Row(
                children: List.generate(7, (i) {
                  final weekday = i + 1;
                  final selected = _days.contains(weekday);
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i == 6 ? 0 : 6),
                      child: GestureDetector(
                        onTap: () => setState(() {
                          selected ? _days.remove(weekday) : _days.add(weekday);
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? accent : scheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? accent : scheme.outlineVariant,
                            ),
                          ),
                          child: Text(
                            AppConstants.weekdayLetters[i],
                            style: text.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: selected ? Colors.white : scheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              label('Colour'),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(HabitOptions.colors.length, (i) {
                  final c = HabitOptions.colors[i];
                  final selected = i == _color;
                  return GestureDetector(
                    onTap: () => setState(() => _color = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? scheme.onSurface : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: selected
                          ? const Icon(Icons.check_rounded,
                              size: 20, color: Colors.white)
                          : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              label('Icon'),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(HabitOptions.icons.length, (i) {
                  final selected = i == _icon;
                  return GestureDetector(
                    onTap: () => setState(() => _icon = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: selected
                            ? accent.withValues(alpha: 0.14)
                            : scheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? accent : scheme.outlineVariant,
                          width: selected ? 1.6 : 1,
                        ),
                      ),
                      child: Icon(
                        HabitOptions.icons[i],
                        color: selected ? accent : scheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: _isEdit ? 'Save changes' : 'Create habit',
                onPressed: _save,
                loading: _saving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
