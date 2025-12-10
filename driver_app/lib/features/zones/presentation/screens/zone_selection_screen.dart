import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/zone_provider.dart';
import '../widgets/zone_list.dart';

class ZoneSelectionScreen extends ConsumerStatefulWidget {
  const ZoneSelectionScreen({super.key});

  @override
  ConsumerState<ZoneSelectionScreen> createState() => _ZoneSelectionScreenState();
}

class _ZoneSelectionScreenState extends ConsumerState<ZoneSelectionScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les zones automatiquement au démarrage (guarded)
    Future.microtask(() async {
      if (!mounted) return;
      await ref.read(zoneProvider.notifier).loadZones();
    });
  }

  @override
  Widget build(BuildContext context) {
    final zoneState = ref.watch(zoneProvider);
    final notifier = ref.read(zoneProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes zones de travail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.loadZones(),
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: zoneState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : zoneState.error != null
                ? Center(child: Text('Erreur : ${zoneState.error}'))
                : Column(
                    children: [
                      Expanded(
                        child: ZoneList(
                          zones: zoneState.zones.map((z) => z.name).toList(),
                          selectedZones: zoneState.zones
                              .where((z) => z.selected)
                              .map((z) => z.name)
                              .toSet(),
                          onZoneToggle: (zoneName) {
                            final zone = zoneState.zones.firstWhere((z) => z.name == zoneName);
                            notifier.toggleZone(zone.id);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: zoneState.zones.any((z) => z.selected)
                            ? () async {
                                  final messenger = ScaffoldMessenger.of(context);
                                  await notifier.saveSelectedZones();
                                  if (!mounted) return;
                                  messenger.showSnackBar(const SnackBar(content: Text('Zones sauvegardées !')));
                                }
                            : null,
                        icon: const Icon(Icons.save),
                        label: const Text('Sauvegarder mes zones'),
                      ),
                    ],
                  ),
      ),
    );
  }
}
