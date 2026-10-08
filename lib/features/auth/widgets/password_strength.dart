import 'package:flutter/material.dart';

import '../../../core/utils/validators.dart';

class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({super.key, required this.password});
  final String password;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final score = Validators.passwordStrength(password);
    const labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
    final colors = [
      scheme.outlineVariant,
      scheme.error,
      const Color(0xFFEA580C),
      const Color(0xFFCA8A04),
      const Color(0xFF16A34A),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            final active = i < score;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 4,
                margin: EdgeInsets.only(right: i == 3 ? 0 : 6),
                decoration: BoxDecoration(
                  color: active ? colors[score] : scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Text(
          score == 0
              ? 'Use 8+ characters with a mix of letters, numbers and symbols'
              : 'Password strength: ${labels[score]}',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
