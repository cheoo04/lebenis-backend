import 'package:flutter/material.dart';

class ZoneTile extends StatelessWidget {
  final String zoneName;
  final bool selected;
  final VoidCallback onTap;

  const ZoneTile({
    super.key,
    required this.zoneName,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      title: Text(
        zoneName,
        style: const TextStyle(fontSize: 14),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
          : const Icon(Icons.radio_button_unchecked, size: 20),
      onTap: onTap,
    );
  }
}
