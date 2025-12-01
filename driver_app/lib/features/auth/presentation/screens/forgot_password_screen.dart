import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_radius.dart';
import '../../../../shared/widgets/modern_button.dart';
import '../../../../shared/widgets/modern_text_field.dart';
import '../../../../shared/utils/validators.dart';
import '../../../../shared/utils/helpers.dart';
import '../../../../core/providers/auth_provider.dart';

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
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Gradient Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.xxxl),
                  bottomRight: Radius.circular(AppRadius.xxxl),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingHorizontal,
                vertical: AppSpacing.xxl,
              ),
              child: Column(
                children: [
                  // Back button
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textWhite),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                    ],
                  ),
                  
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.textWhite.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      size: 40,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Title
                  Text(
                    _codeSent ? 'Entrez le code' : 'Mot de passe oublié',
                    style: AppTypography.h2.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  
                  // Description
                  Text(
                    _codeSent
                        ? 'Code envoyé à $_email'
                        : 'Entrez votre email pour recevoir un code',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textWhite.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.xl),

                      if (!_codeSent) ...[
                        // Email Field
                        ModernTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'exemple@email.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                          enabled: !_isSubmitting,
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Send Code Button
                        ModernButton(
                          text: 'Envoyer le code',
                          onPressed: _isSubmitting ? null : _sendResetCode,
                          isLoading: _isSubmitting,
                          icon: Icons.send,
                          type: ModernButtonType.primary,
                          size: ModernButtonSize.large,
                          fullWidth: true,
                        ),
                      ] else ...[
                        // Code Field
                        ModernTextField(
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

                        const SizedBox(height: AppSpacing.lg),

                        // New Password Field
                        ModernTextField(
                          controller: _passwordController,
                          label: 'Nouveau mot de passe',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          obscureText: !_isPasswordVisible,
                          suffixIcon: _isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          onSuffixIconTap: () {
                            setState(() => _isPasswordVisible = !_isPasswordVisible);
                          },
                          validator: Validators.validatePassword,
                          enabled: !_isSubmitting,
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Confirm Password Field
                        ModernTextField(
                          controller: _passwordConfirmController,
                          label: 'Confirmer le mot de passe',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          obscureText: !_isPasswordConfirmVisible,
                          suffixIcon: _isPasswordConfirmVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          onSuffixIconTap: () {
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

                        const SizedBox(height: AppSpacing.xl),

                        // Reset Password Button
                        ModernButton(
                          text: 'Réinitialiser le mot de passe',
                          onPressed: _isSubmitting ? null : _resetPassword,
                          isLoading: _isSubmitting,
                          icon: Icons.check,
                          type: ModernButtonType.success,
                          size: ModernButtonSize.large,
                          fullWidth: true,
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Resend Code Button
                        ModernButton(
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
                          type: ModernButtonType.outlined,
                          size: ModernButtonSize.large,
                          fullWidth: true,
                        ),
                      ],

                      const SizedBox(height: AppSpacing.xl),

                      // Back to Login
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Retour à la connexion',
                            style: AppTypography.label.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
