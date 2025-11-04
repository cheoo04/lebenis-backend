// lib/main_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/auth_service.dart';
import 'core/network/dio_client.dart';
import 'data/repositories/driver_repository.dart';
import 'data/repositories/delivery_repository.dart';

void main() {
  runApp(const ProviderScope(child: TestApp()));
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeBeni\'s API Test',
      home: const TestScreen(),
    );
  }
}

class TestScreen extends ConsumerStatefulWidget {
  const TestScreen({super.key});

  @override
  ConsumerState<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends ConsumerState<TestScreen> {
  String _output = 'Appuyez sur un bouton pour tester\n';

  void _addLog(String message) {
    setState(() {
      _output += '$message\n';
    });
  }

  Future<void> _runTests() async {
    _output = '';
    _addLog('Démarrage des tests...\n');

    try {
      final authService = AuthService();
      final dioClient = DioClient(authService);
      final driverRepository = DriverRepository(dioClient);
      final deliveryRepository = DeliveryRepository(dioClient);  // ← AJOUTER CETTE LIGNE
      
      _addLog(' Services initialisés');

      // Test 1: Get Profile
      _addLog('\n📌 Récupération du profil...');
      try {
        final driver = await driverRepository.getMyProfile();
        _addLog(' Profil: ${driver.user.fullName}');
      } catch (e) {
        _addLog(' Profil: $e');
      }

      // Test 2: Get Deliveries
      _addLog('\n📌 Récupération des livraisons...');
      try {
        final deliveries = await deliveryRepository.getMyDeliveries();
        _addLog(' Livraisons: ${deliveries.length} trouvées');
      } catch (e) {
        _addLog(' Livraisons: $e');
      }

      _addLog('\n Tests terminés!');
    } catch (e) {
      _addLog('\n Erreur globale: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LeBeni\'s API Test'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                _output,
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _runTests,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text('Lancer les tests'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
