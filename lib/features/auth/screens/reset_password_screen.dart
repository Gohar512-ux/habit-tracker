import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/snack.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/password_strength.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, this.initialCode});

  /// Pre-fills the code when the screen is opened from a deep link.
  final String? initialCode;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _code =
      TextEditingController(text: widget.initialCode);
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _done = false;

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final result = await context.read<AuthProvider>().resetPassword(
          code: _code.text.trim(),
          newPassword: _password.text,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.success) {
      setState(() => _done = true);
    } else {
      showAppSnack(context, result.message!, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _buildDone(context);

    return AuthScaffold(
      showBack: true,
      title: 'Set a new password',
      subtitle:
          'Paste the reset code from your email, then choose a new password.',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _code,
                label: 'Reset code',
                hint: 'Code from your email',
                icon: Icons.pin_outlined,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.required(v, 'Enter the reset code'),
              ),
              const SizedBox(height: 18),
              AppTextField(
                controller: _password,
                label: 'New password',
                hint: 'Create a new password',
                icon: Icons.lock_outline_rounded,
                obscure: true,
                textInputAction: TextInputAction.next,
                validator: Validators.password,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),
              PasswordStrengthMeter(password: _password.text),
              const SizedBox(height: 18),
              AppTextField(
                controller: _confirm,
                label: 'Confirm new password',
                hint: 'Re-enter the new password',
                icon: Icons.lock_outline_rounded,
                obscure: true,
                textInputAction: TextInputAction.done,
                validator: (v) => Validators.confirmPassword(v, _password.text),
                onSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        PrimaryButton(
          label: 'Reset password',
          onPressed: _submit,
          loading: _loading,
        ),
      ],
    );
  }

  Widget _buildDone(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AuthScaffold(
      title: 'Password updated',
      subtitle: 'Your password has been changed. Sign in with your new password.',
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF16A34A).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.check_rounded, color: scheme.primary, size: 32),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          label: 'Back to sign in',
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
      ],
    );
  }
}
