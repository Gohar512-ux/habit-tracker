import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/snack.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/password_strength.dart';
import '../widgets/social_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _googleLoading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _closeAuthStack() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final result = await context.read<AuthProvider>().signUp(
          name: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.success) {
      _closeAuthStack();
    } else {
      showAppSnack(context, result.message!, error: true);
    }
  }

  Future<void> _google() async {
    setState(() => _googleLoading = true);
    final result = await context.read<AuthProvider>().signInWithGoogle();
    if (!mounted) return;
    setState(() => _googleLoading = false);
    if (result.success) {
      _closeAuthStack();
    } else if (!result.cancelled) {
      showAppSnack(context, result.message!, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      title: 'Create your account',
      subtitle: 'Build routines that stick. It only takes a minute to get started.',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _name,
                label: 'Full name',
                hint: 'Your name',
                icon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                validator: Validators.name,
              ),
              const SizedBox(height: 18),
              AppTextField(
                controller: _email,
                label: 'Email',
                hint: 'you@example.com',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: Validators.email,
              ),
              const SizedBox(height: 18),
              AppTextField(
                controller: _password,
                label: 'Password',
                hint: 'Create a password',
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
                label: 'Confirm password',
                hint: 'Re-enter your password',
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
        PrimaryButton(label: 'Create account', onPressed: _submit, loading: _loading),
        const SizedBox(height: 24),
        const OrDivider(),
        const SizedBox(height: 24),
        GoogleButton(onPressed: _google, loading: _googleLoading),
        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Already have an account? Sign in'),
          ),
        ),
      ],
    );
  }
}
