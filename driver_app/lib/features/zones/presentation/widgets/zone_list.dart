import 'package:flutter/material.dart';
import 'zone_tile.dart';

class ZoneList extends StatelessWidget {
  final List<String> zones;
  final Set<String> selectedZones;
  final void Function(String) onZoneToggle;

  const ZoneList({
    super.key,
    required this.zones,
    required this.selectedZones,
    required this.onZoneToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: zones.length,
      itemBuilder: (context, index) {
        final zone = zones[index];
        return ZoneTile(
          zoneName: zone,
          selected: selectedZones.contains(zone),
          onTap: () => onZoneToggle(zone),
        );
      },
    );
  }
}
