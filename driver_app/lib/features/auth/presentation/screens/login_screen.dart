import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_radius.dart';
import '../../../../shared/widgets/modern_button.dart';
import '../../../../shared/widgets/modern_text_field.dart';
import '../../../../shared/utils/validators.dart';
import '../../../../shared/utils/helpers.dart';
import '../../../chat/providers/chat_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Unfocus keyboard
    Helpers.unfocus(context);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      await ref.read(authProvider.notifier).login(email, password);

      if (!mounted) return;

      final authState = ref.read(authProvider);

      if (authState.isLoggedIn) {
        // Enregistrer le token FCM après connexion réussie
        ref.read(chatNotificationServiceProvider).registerTokenAfterLogin();
        
        Helpers.showSuccessSnackBar(context, 'Connexion réussie!');
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (authState.error != null) {
        Helpers.showErrorSnackBar(context, authState.error!);
      }
    } catch (e) {
      if (!mounted) return;
      // Ne pas afficher l'erreur ici car elle est déjà dans authState.error
      // et sera affichée par le widget d'erreur en bas de l'écran
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).pushNamed('/register');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header avec gradient vert
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.greenGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.xxxl),
                  bottomRight: Radius.circular(AppRadius.xxxl),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingHorizontal,
                vertical: AppSpacing.xxxl,
              ),
              child: Column(
                children: [
                  // Icône
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.textWhite.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      size: 40,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Titre
                  Text(
                    'Connexion',
                    style: AppTypography.h2.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  
                  Text(
                    'Connectez-vous pour commencer',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textWhite.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Formulaire
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.xxl),
                      
                      // Email Field
                      ModernTextField(
                        controller: _emailController,
                        label: 'Adresse Email',
                        hint: 'exemple@email.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (value) => Validators.validateEmail(value ?? ''),
                        enabled: !isLoading,
                      ),
                      
                      const SizedBox(height: AppSpacing.lg),
                      
                      // Password Field
                      ModernTextField(
                        controller: _passwordController,
                        label: 'Mot de passe',
                        hint: '••••••••',
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock_outlined,
                        suffixIcon: _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        onSuffixIconTap: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        validator: (value) => Validators.validateRequired(value, fieldName: 'Mot de passe'),
                        enabled: !isLoading,
                      ),
                      
                      const SizedBox(height: AppSpacing.md),
                      
                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isLoading ? null : () {
                            Navigator.of(context).pushNamed('/forgot-password');
                          },
                          child: Text(
                            'Mot de passe oublié?',
                            style: AppTypography.link,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.xl),
                      
                      // Error Message
                      if (authState.error != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.error, width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  authState.error!,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Login Button
                      ModernButton(
                        text: 'Se connecter',
                        onPressed: _handleLogin,
                        isLoading: isLoading,
                        icon: Icons.login,
                        type: ModernButtonType.primary,
                        size: ModernButtonSize.large,
                      ),
                      
                      const SizedBox(height: AppSpacing.lg),
                      
                      // Texte "Pas de compte"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Pas encore de compte? ',
                            style: AppTypography.bodyMedium,
                          ),
                          TextButton(
                            onPressed: isLoading ? null : _navigateToRegister,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Créer un compte',
                              style: AppTypography.link,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppSpacing.xxl),
                      
                      // Version Info
                      Center(
                        child: Text(
                          'Version 1.0.0',
                          style: AppTypography.caption,
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
