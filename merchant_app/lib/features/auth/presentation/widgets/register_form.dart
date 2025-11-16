import 'package:flutter/material.dart';

class RegisterForm extends StatelessWidget {
  final void Function(String email, String password, String confirmPassword) onRegister;
  const RegisterForm({required this.onRegister, super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          decoration: const InputDecoration(labelText: 'Mot de passe'),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: confirmPasswordController,
          decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
          obscureText: true,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => onRegister(
            emailController.text,
            passwordController.text,
            confirmPasswordController.text,
          ),
          child: const Text("S'inscrire"),
        ),
      ],
    );
  }
}
