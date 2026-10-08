import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/snack.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/auth_scaffold.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final result =
        await context.read<AuthProvider>().sendPasswordReset(_email.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.success) {
      setState(() => _sent = true);
    } else {
      showAppSnack(context, result.message!, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) return _buildSent(context);

    return AuthScaffold(
      showBack: true,
      title: 'Forgot password?',
      subtitle:
          "Enter the email linked to your account and we'll send you instructions to reset your password.",
      children: [
        Form(
          key: _formKey,
          child: AppTextField(
            controller: _email,
            label: 'Email',
            hint: 'you@example.com',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: Validators.email,
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(height: 28),
        PrimaryButton(
          label: 'Send reset email',
          onPressed: _submit,
          loading: _loading,
        ),
      ],
    );
  }

  Widget _buildSent(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return AuthScaffold(
      showBack: true,
      title: 'Check your inbox',
      subtitle: 'We sent password reset instructions to ${_email.text.trim()}.',
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 20, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Can't find it? Check your spam folder. The link expires after a short time for your security.",
                  style: text.bodyMedium?.copyWith(height: 1.45),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        PrimaryButton(
          label: 'I have a reset code',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          child: const Text('Back to sign in'),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _sent = false),
            child: const Text('Use a different email'),
          ),
        ),
      ],
    );
  }
}
