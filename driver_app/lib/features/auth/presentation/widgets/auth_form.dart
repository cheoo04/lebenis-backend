import 'package:flutter/material.dart';
import '../../../../shared/theme/dimensions.dart';
import '../../../../shared/widgets/custom_textfield.dart';
import '../../../../shared/utils/validators.dart';

/// Common authentication form fields used across login and register screens
class AuthForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController? passwordConfirmController;
  final bool isPasswordVisible;
  final VoidCallback onTogglePasswordVisibility;
  final bool showPasswordConfirm;
  final bool enabled;

  const AuthForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    this.passwordConfirmController,
    required this.isPasswordVisible,
    required this.onTogglePasswordVisibility,
    this.showPasswordConfirm = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          controller: emailController,
          label: 'Email',
          hint: 'exemple@email.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (value) => Validators.validateEmail(value ?? ''),
          enabled: enabled,
        ),
        
        const SizedBox(height: Dimensions.spacingM),
        
        CustomTextField(
          controller: passwordController,
          label: 'Mot de passe',
          hint: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: !isPasswordVisible,
          textInputAction: showPasswordConfirm ? TextInputAction.next : TextInputAction.done,
          // pass the IconButton via `suffix` (widget) rather than `suffixIcon` which expects IconData
          suffix: IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: enabled ? onTogglePasswordVisibility : null,
          ),
          validator: (value) => Validators.validatePassword(value ?? ''),
          enabled: enabled,
        ),

        if (showPasswordConfirm) ...[
          const SizedBox(height: Dimensions.spacingM),
          
          CustomTextField(
            controller: passwordConfirmController!,
            label: 'Confirmer le mot de passe',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline,
            obscureText: !isPasswordVisible,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez confirmer votre mot de passe';
              }
              if (value != passwordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
            enabled: enabled,
          ),
        ],
      ],
    );
  }
}
