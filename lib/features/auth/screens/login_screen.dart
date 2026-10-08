import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/snack.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/social_button.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _googleLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final result = await context
        .read<AuthProvider>()
        .signIn(email: _email.text.trim(), password: _password.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (!result.success) showAppSnack(context, result.message!, error: true);
  }

  Future<void> _google() async {
    setState(() => _googleLoading = true);
    final result = await context.read<AuthProvider>().signInWithGoogle();
    if (!mounted) return;
    setState(() => _googleLoading = false);
    if (!result.success && !result.cancelled) {
      showAppSnack(context, result.message!, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to pick up your streaks right where you left off.',
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              children: [
                AppTextField(
                  controller: _email,
                  label: 'Email',
                  hint: 'you@example.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: Validators.email,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  controller: _password,
                  label: 'Password',
                  hint: 'Enter your password',
                  icon: Icons.lock_outline_rounded,
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  validator: Validators.loginPassword,
                  onSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
            ),
            child: const Text('Forgot password?'),
          ),
        ),
        const SizedBox(height: 8),
        PrimaryButton(label: 'Sign in', onPressed: _submit, loading: _loading),
        const SizedBox(height: 24),
        const OrDivider(),
        const SizedBox(height: 24),
        GoogleButton(onPressed: _google, loading: _googleLoading),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account?",
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SignUpScreen()),
              ),
              child: const Text('Sign up'),
            ),
          ],
        ),
      ],
    );
  }
}
