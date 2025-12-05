import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/merchant_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
	const SplashScreen({super.key});

	@override
	ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
	@override
	void initState() {
		super.initState();
		WidgetsBinding.instance.addPostFrameCallback((_) {
			_checkAuthAndRedirect();
		});
	}

	Future<void> _checkAuthAndRedirect() async {
		try {
			final auth = ref.read(authStateProvider);
			
			// Si pas connecté, aller sur login
			if (auth.value == null) {
				if (mounted) Navigator.pushReplacementNamed(context, '/login');
				return;
			}
			
			// Charger le profil marchand
			await ref.read(merchantProfileProvider.notifier).loadProfile();
			
			// Attendre un peu pour que le provider soit mis à jour
			await Future.delayed(const Duration(milliseconds: 100));
			
			final profileState = ref.read(merchantProfileProvider);
			
		// Gérer les erreurs de chargement du profil
		if (profileState.hasError) {
			debugPrint('Erreur chargement profil: ${profileState.error}');
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text('Erreur: ${profileState.error}'),
						backgroundColor: Colors.red,
						duration: const Duration(seconds: 3),
					),
				);
				await Future.delayed(const Duration(seconds: 1));
				Navigator.pushReplacementNamed(context, '/login');
			}
			return;
		}			if (profileState.value == null) {
				if (mounted) Navigator.pushReplacementNamed(context, '/login');
				return;
			}
			
			final profile = profileState.value!;
			debugPrint('Profil chargé - statut: ${profile.verificationStatus}');
			
			if (profile.verificationStatus == 'approved' || profile.verificationStatus == 'verified') {
				if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
			} else if (profile.verificationStatus == 'pending') {
				if (mounted) Navigator.pushReplacementNamed(context, '/waiting-approval');
			} else if (profile.verificationStatus == 'rejected') {
				if (mounted) Navigator.pushReplacementNamed(context, '/rejected');
			} else {
				if (mounted) Navigator.pushReplacementNamed(context, '/login');
			}
		} catch (e) {
			debugPrint('Erreur lors de la vérification: $e');
			if (mounted) Navigator.pushReplacementNamed(context, '/login');
		}
	}

	@override
	Widget build(BuildContext context) {
		return const Scaffold(
			body: Center(
				child: CircularProgressIndicator(),
			),
		);
	}
}
