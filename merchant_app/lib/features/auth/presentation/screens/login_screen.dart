import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/merchant_provider.dart';
import '../../../../core/providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final authNotifier = ref.read(authStateProvider.notifier);
    await authNotifier.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AsyncValue<dynamic>>(authStateProvider, (previous, next) {
      // Éviter les doublons de navigation
      if (!mounted) return;
      
      next.when(
        data: (user) {
          if (user != null && previous?.value == null) {
            // Connexion réussie
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Connexion réussie !'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 1),
              ),
            );
            
            // Enregistrer le token FCM
            ref.read(notificationServiceProvider).registerTokenAfterLogin();
            
            // Rediriger immédiatement vers splash qui gère la logique
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          }
        },
        loading: () {},
        error: (err, _) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${err.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Logo/Titre
              Text(
                'LeBeni',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
              // Email
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // Mot de passe
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Bouton Connexion
              authState.maybeWhen(
                loading: () => const ElevatedButton(
                  onPressed: null,
                  child: CircularProgressIndicator(),
                ),
                orElse: () => ElevatedButton(
                  onPressed: _login,
                  child: const Text('Se connecter'),
                ),
              ),
              const SizedBox(height: 16),
              // Lien Inscription
              Center(
                child: TextButton(
                  onPressed: () {
                    // Naviguer vers UserTypeSelectionScreen
                    Navigator.pushNamed(context, '/user-type-selection');
                  },
                  child: const Text('Créer un compte'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}