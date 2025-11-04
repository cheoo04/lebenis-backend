import 'package:flutter/material.dart';
import '../../../../shared/theme/dimensions.dart';
import '../../../../shared/theme/text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import 'auth_form.dart';

/// Login-specific form wrapper with submit button and forgot password link
class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isPasswordVisible;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onSubmit;
  final VoidCallback? onForgotPassword;
  final bool isLoading;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isPasswordVisible,
    required this.onTogglePasswordVisibility,
    required this.onSubmit,
    this.onForgotPassword,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthForm(
            emailController: emailController,
            passwordController: passwordController,
            isPasswordVisible: isPasswordVisible,
            onTogglePasswordVisibility: onTogglePasswordVisibility,
            enabled: !isLoading,
          ),
          
          if (onForgotPassword != null) ...[
            const SizedBox(height: Dimensions.spacingS),
            
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isLoading ? null : onForgotPassword,
                child: Text(
                  'Mot de passe oublié?',
                  style: TextStyles.link,
                ),
              ),
            ),
          ],
          
          const SizedBox(height: Dimensions.spacingXL),
          
          CustomButton(
            text: 'Se connecter',
            onPressed: isLoading ? null : onSubmit,
            isLoading: isLoading,
            icon: Icons.login,
          ),
        ],
      ),
    );
  }
}
