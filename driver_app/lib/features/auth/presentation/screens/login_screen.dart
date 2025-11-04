import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/dimensions.dart';
import '../../../../shared/theme/text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_textfield.dart';
import '../../../../shared/utils/validators.dart';
import '../../../../shared/utils/helpers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: Dimensions.spacingXXL),
                
                // Logo
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(Dimensions.radiusL),
                    ),
                    child: const Icon(
                      Icons.local_shipping,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: Dimensions.spacingXL),
                
                // Title
                Text(
                  'Connexion',
                  style: TextStyles.h1,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: Dimensions.spacingS),
                
                Text(
                  'Connectez-vous pour commencer à livrer',
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: Dimensions.spacingXXL),
                
                // Email Field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'exemple@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) => Validators.validateEmail(value ?? ''),
                  enabled: !isLoading,
                ),
                
                const SizedBox(height: Dimensions.spacingL),
                
                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  hint: '••••••••',
                  obscureText: true,
                  prefixIcon: Icons.lock_outlined,
                  validator: (value) => Validators.validateRequired(value, fieldName: 'Mot de passe'),
                  enabled: !isLoading,
                ),
                
                const SizedBox(height: Dimensions.spacingM),
                
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading ? null : () {
                      Helpers.showSnackBar(context, 'Fonctionnalité à venir');
                    },
                    child: Text(
                      'Mot de passe oublié?',
                      style: TextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: Dimensions.spacingXL),
                
                // Login Button
                CustomButton(
                  text: 'Se connecter',
                  onPressed: _handleLogin,
                  isLoading: isLoading,
                  icon: Icons.login,
                ),
                
                const SizedBox(height: Dimensions.spacingXL),
                
                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.spacingM),
                      child: Text(
                        'OU',
                        style: TextStyles.caption,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                
                const SizedBox(height: Dimensions.spacingXL),
                
                // Register Button
                OutlineButton(
                  text: 'Créer un compte',
                  onPressed: isLoading ? null : _navigateToRegister,
                  icon: Icons.person_add_outlined,
                ),
                
                const SizedBox(height: Dimensions.spacingL),
                
                // Version Info
                Center(
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyles.caption,
                  ),
                ),
                
                const SizedBox(height: Dimensions.spacingM),
                
                // Error Message
                if (authState.error != null)
                  Container(
                    padding: const EdgeInsets.all(Dimensions.spacingM),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Dimensions.radiusM),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: Dimensions.spacingS),
                        Expanded(
                          child: Text(
                            authState.error!,
                            style: TextStyles.bodySmall.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
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
