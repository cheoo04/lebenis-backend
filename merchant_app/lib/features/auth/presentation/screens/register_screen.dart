import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/providers/auth_provider.dart';


class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _password2Controller;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _businessNameController;
  late final TextEditingController _businessTypeController;
  late final TextEditingController _businessAddressController;
  String? _rccmDocumentPath;
  String? _idDocumentPath;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _password2Controller = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _businessNameController = TextEditingController();
    _businessTypeController = TextEditingController();
    _businessAddressController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _password2Controller.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    _businessTypeController.dispose();
    _businessAddressController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final picker = ImagePicker();
    final rccm = await picker.pickImage(source: ImageSource.gallery);
    if (rccm != null) {
      setState(() => _rccmDocumentPath = rccm.path);
    }
    final idDoc = await picker.pickImage(source: ImageSource.gallery);
    if (idDoc != null) {
      setState(() => _idDocumentPath = idDoc.path);
    }
  }

  void _register() async {
    final authNotifier = ref.read(authStateProvider.notifier);
    await authNotifier.register(
      email: _emailController.text,
      password: _passwordController.text,
      password2: _password2Controller.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phone: _phoneController.text,
      businessName: _businessNameController.text,
      businessType: _businessTypeController.text,
      businessAddress: _businessAddressController.text,
      rccmDocumentPath: _rccmDocumentPath,
      idDocumentPath: _idDocumentPath,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      authState.whenOrNull(
        error: (err, _) {
          if (err != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(err.toString())),
            );
          }
        },
      );
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              // Prénom
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              // Nom
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              // Téléphone
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
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
              const SizedBox(height: 16),
              // Confirmation mot de passe
              TextField(
                controller: _password2Controller,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 16),
              // Nom du commerce
              TextField(
                controller: _businessNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du commerce',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                ),
              ),
              const SizedBox(height: 16),
              // Type de commerce
              TextField(
                controller: _businessTypeController,
                decoration: const InputDecoration(
                  labelText: 'Type de commerce',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 16),
              // Adresse du commerce
              TextField(
                controller: _businessAddressController,
                decoration: const InputDecoration(
                  labelText: 'Adresse du commerce',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              // Upload RCCM
              ElevatedButton(
                onPressed: () async {
                  final picker = ImagePicker();
                  final rccm = await picker.pickImage(source: ImageSource.gallery);
                  if (rccm != null) {
                    setState(() => _rccmDocumentPath = rccm.path);
                  }
                },
                child: Text(
                  _rccmDocumentPath == null
                      ? 'Télécharger RCCM'
                      : 'RCCM sélectionné ✓',
                ),
              ),
              const SizedBox(height: 16),
              // Upload pièce d'identité
              ElevatedButton(
                onPressed: () async {
                  final picker = ImagePicker();
                  final idDoc = await picker.pickImage(source: ImageSource.gallery);
                  if (idDoc != null) {
                    setState(() => _idDocumentPath = idDoc.path);
                  }
                },
                child: Text(
                  _idDocumentPath == null
                      ? "Télécharger pièce d'identité"
                      : "Pièce d'identité sélectionnée ✓",
                ),
              ),
              const SizedBox(height: 24),
              // Bouton Inscription
              authState.maybeWhen(
                loading: () => const ElevatedButton(
                  onPressed: null,
                  child: CircularProgressIndicator(),
                ),
                orElse: () => ElevatedButton(
                  onPressed: _register,
                  child: const Text('S\'inscrire'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}