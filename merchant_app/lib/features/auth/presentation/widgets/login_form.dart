import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final void Function(String email, String password) onLogin;
  const LoginForm({required this.onLogin, super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
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
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => onLogin(emailController.text, passwordController.text),
          child: const Text('Se connecter'),
        ),
      ],
    );
  }
}
