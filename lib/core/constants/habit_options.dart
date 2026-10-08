import 'package:flutter/material.dart';

class HabitOptions {
  HabitOptions._();

  static const List<IconData> icons = [
    Icons.fitness_center_rounded,
    Icons.menu_book_rounded,
    Icons.water_drop_rounded,
    Icons.self_improvement_rounded,
    Icons.directions_run_rounded,
    Icons.bedtime_rounded,
    Icons.restaurant_rounded,
    Icons.code_rounded,
    Icons.savings_rounded,
    Icons.edit_note_rounded,
    Icons.music_note_rounded,
    Icons.eco_rounded,
    Icons.medication_rounded,
    Icons.brush_rounded,
    Icons.smoke_free_rounded,
    Icons.pets_rounded,
    Icons.wb_sunny_rounded,
    Icons.favorite_rounded,
  ];

  static const List<Color> colors = [
    Color(0xFF0F766E),
    Color(0xFF2563EB),
    Color(0xFF7C3AED),
    Color(0xFFDB2777),
    Color(0xFFEA580C),
    Color(0xFFCA8A04),
    Color(0xFF16A34A),
    Color(0xFF475569),
  ];

  static IconData iconAt(int i) => icons[i.clamp(0, icons.length - 1)];
  static Color colorAt(int i) => colors[i.clamp(0, colors.length - 1)];
}
