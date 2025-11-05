import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/dimensions.dart';
import '../../../../shared/theme/text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_textfield.dart';
import '../../../../shared/utils/validators.dart';
import '../../../../shared/utils/helpers.dart';
import '../../../../data/providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isPasswordConfirmVisible = false;
  bool _isSubmitting = false;
  bool _codeSent = false;
  String? _email;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final success = await ref.read(authProvider.notifier).requestPasswordReset(
        _emailController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        setState(() {
          _codeSent = true;
          _email = _emailController.text.trim();
        });
        Helpers.showSuccessSnackBar(
          context,
          'Code envoyé ! Vérifiez votre email.',
        );
      } else {
        Helpers.showErrorSnackBar(
          context,
          'Erreur lors de l\'envoi du code',
        );
      }
    } catch (e) {
      if (!mounted) return;
      Helpers.showErrorSnackBar(context, e.toString());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _passwordConfirmController.text) {
      Helpers.showErrorSnackBar(
        context,
        'Les mots de passe ne correspondent pas',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final success = await ref.read(authProvider.notifier).confirmPasswordReset(
        email: _email!,
        code: _codeController.text.trim(),
        newPassword: _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        Helpers.showSuccessSnackBar(
          context,
          'Mot de passe réinitialisé ! Vous pouvez vous connecter.',
        );
        Navigator.of(context).pop();
      } else {
        Helpers.showErrorSnackBar(
          context,
          'Erreur lors de la réinitialisation',
        );
      }
    } catch (e) {
      if (!mounted) return;
      Helpers.showErrorSnackBar(context, e.toString());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe oublié'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: Dimensions.spacingXL),

                // Icon
                Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: AppColors.primary,
                ),

                const SizedBox(height: Dimensions.spacingXL),

                // Title
                Text(
                  _codeSent ? 'Entrez le code' : 'Réinitialiser le mot de passe',
                  style: TextStyles.h2,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: Dimensions.spacingM),

                // Description
                Text(
                  _codeSent
                      ? 'Un code à 6 chiffres a été envoyé à $_email'
                      : 'Entrez votre email pour recevoir un code de réinitialisation',
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: Dimensions.spacingXXL),

                if (!_codeSent) ...[
                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'exemple@email.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    enabled: !_isSubmitting,
                  ),

                  const SizedBox(height: Dimensions.spacingXL),

                  // Send Code Button
                  CustomButton(
                    text: 'Envoyer le code',
                    onPressed: _isSubmitting ? null : _sendResetCode,
                    isLoading: _isSubmitting,
                    icon: Icons.send,
                  ),
                ] else ...[
                  // Code Field
                  CustomTextField(
                    controller: _codeController,
                    label: 'Code de vérification',
                    hint: '123456',
                    prefixIcon: Icons.pin,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Code requis';
                      }
                      if (value.length != 6) {
                        return 'Le code doit contenir 6 chiffres';
                      }
                      return null;
                    },
                    enabled: !_isSubmitting,
                  ),

                  const SizedBox(height: Dimensions.spacingL),

                  // New Password Field
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Nouveau mot de passe',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    obscureText: !_isPasswordVisible,
                    suffixIcon: _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    onSuffixTap: () {
                      setState(() => _isPasswordVisible = !_isPasswordVisible);
                    },
                    validator: Validators.validatePassword,
                    enabled: !_isSubmitting,
                  ),

                  const SizedBox(height: Dimensions.spacingL),

                  // Confirm Password Field
                  CustomTextField(
                    controller: _passwordConfirmController,
                    label: 'Confirmer le mot de passe',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    obscureText: !_isPasswordConfirmVisible,
                    suffixIcon: _isPasswordConfirmVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    onSuffixTap: () {
                      setState(() => _isPasswordConfirmVisible = !_isPasswordConfirmVisible);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirmation requise';
                      }
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                    enabled: !_isSubmitting,
                  ),

                  const SizedBox(height: Dimensions.spacingXL),

                  // Reset Password Button
                  CustomButton(
                    text: 'Réinitialiser le mot de passe',
                    onPressed: _isSubmitting ? null : _resetPassword,
                    isLoading: _isSubmitting,
                    icon: Icons.check,
                  ),

                  const SizedBox(height: Dimensions.spacingL),

                  // Resend Code Button
                  OutlineButton(
                    text: 'Renvoyer le code',
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            setState(() {
                              _codeSent = false;
                              _codeController.clear();
                              _passwordController.clear();
                              _passwordConfirmController.clear();
                            });
                          },
                    icon: Icons.refresh,
                  ),
                ],

                const SizedBox(height: Dimensions.spacingXL),

                // Back to Login
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Retour à la connexion',
                    style: TextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
