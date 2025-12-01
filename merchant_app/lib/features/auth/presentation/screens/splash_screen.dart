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
		final auth = ref.read(authStateProvider);
		// Si pas connecté, aller sur login
		if (auth.value == null) {
			if (mounted) Navigator.pushReplacementNamed(context, '/login');
			return;
		}
		// Charger le profil marchand
		await ref.read(merchantProfileProvider.notifier).loadProfile();
		final profileState = ref.read(merchantProfileProvider);
		if (profileState.value == null) {
			if (mounted) Navigator.pushReplacementNamed(context, '/login');
			return;
		}
		final profile = profileState.value!;
		if (profile.verificationStatus == 'approved') {
			if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
		} else if (profile.verificationStatus == 'pending') {
			if (mounted) Navigator.pushReplacementNamed(context, '/waiting-approval');
		} else if (profile.verificationStatus == 'rejected') {
			if (mounted) Navigator.pushReplacementNamed(context, '/rejected');
		} else {
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
