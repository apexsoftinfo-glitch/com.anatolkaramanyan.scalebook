import 'package:flutter/material.dart';
import 'package:scalebook/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import '../../../core/design_system/app_colors.dart';
import '../../../core/config/api_keys.dart';
import '../../session/domain/repositories/session_repository.dart';

class AuthScreen extends StatefulWidget {
  final bool isRegister;
  const AuthScreen({super.key, this.isRegister = false});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.isRegister ? S.of(context).register : S.of(context).login; // L10N

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/workbench_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          // Dark Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(0), // Tamiya flat style
                    border: Border.all(color: AppColors.navyBlue, width: 4),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.lock_person_rounded,
                          size: 60,
                          color: AppColors.navyBlue,
                        ),
                        const SizedBox(height: 12),
                        const SizedBox(height: 12),
                        Text(
                          S.of(context).techAuth, // L10N
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: AppColors.red,
                          ),
                        ),
                        if (!ApiKeys.isSupabaseConfigured)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            color: AppColors.red.withValues(alpha: 0.1),
                            child: Text(
                              S.of(context).demoModeWarning, // L10N
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: S.of(context).email, // L10N
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v?.isEmpty ?? true ? S.of(context).required : null, // L10N
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: S.of(context).password, // L10N
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                          validator: (v) => v?.isEmpty ?? true ? S.of(context).required : null, // L10N
                        ),
                        const SizedBox(height: 24),
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.navyBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: const RoundedRectangleBorder(),
                            ),
                            child: Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        if (!widget.isRegister) ...[
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton.icon(
                              onPressed: _showResetPasswordDialog,
                              icon: const Icon(Icons.help_outline, size: 16, color: AppColors.navyBlue),
                              label: Text(
                                S.of(context).forgotPassword,
                                style: const TextStyle(
                                  color: AppColors.navyBlue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final repo = GetIt.I<SessionRepository>();
        if (widget.isRegister) {
          await repo.signUpWithEmail(_emailController.text, _passwordController.text);
        } else {
          await repo.signInWithEmail(_emailController.text, _passwordController.text);
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_mapAuthError(e.toString())),
              backgroundColor: AppColors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  String _mapAuthError(String error) {
    final lowerError = error.toLowerCase();
    if (lowerError.contains('user_already_exists') || lowerError.contains('user already registered')) {
      return S.of(context).errorUserAlreadyExists;
    }
    if (lowerError.contains('invalid login credentials') || lowerError.contains('invalid_credentials')) {
      return S.of(context).errorInvalidCredentials;
    }
    if (lowerError.contains('network') || lowerError.contains('socketexception')) {
      return S.of(context).errorNetworkProblem;
    }
    if (lowerError.contains('password')) {
      return S.of(context).errorWeakPassword;
    }
    return S.of(context).errorUnexpectedAuth;
  }

  void _showResetPasswordDialog() {
    final emailController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).resetPasswordTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(S.of(context).resetPasswordDescription),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: S.of(context).email,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;

              try {
                final repo = GetIt.I<SessionRepository>();
                await repo.resetPassword(email);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(S.of(context).resetLinkSent),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(S.of(context).error(e.toString())),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navyBlue,
              foregroundColor: Colors.white,
            ),
            child: Text(S.of(context).sendResetLink),
          ),
        ],
      ),
    );
  }
}
