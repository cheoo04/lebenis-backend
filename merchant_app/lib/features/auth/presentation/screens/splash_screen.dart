import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/user_profile_provider.dart';
import '../../../../data/models/merchant_model.dart';

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
			
		// Charger le profil utilisateur (merchant ou individual)
		await ref.read(userProfileProvider.notifier).loadProfile();
		
		// Attendre un peu plus pour que le provider soit mis à jour
		await Future.delayed(const Duration(milliseconds: 300));
		
		final profileState = ref.read(userProfileProvider);		// Gérer les erreurs de chargement du profil
		if (profileState.hasError) {
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
			
			// Cas merchant: vérifier le statut de vérification
			if (profile is MerchantModel) {
				
				if (profile.verificationStatus == 'approved' || profile.verificationStatus == 'verified') {
					if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
				} else if (profile.verificationStatus == 'pending') {
					if (mounted) Navigator.pushReplacementNamed(context, '/waiting-approval');
				} else if (profile.verificationStatus == 'rejected') {
					if (mounted) Navigator.pushReplacementNamed(context, '/rejected');
				} else {
					if (mounted) Navigator.pushReplacementNamed(context, '/login');
				}
			} else {
				// Cas particulier: aller directement au dashboard
				if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
			}
		} catch (e) {
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
