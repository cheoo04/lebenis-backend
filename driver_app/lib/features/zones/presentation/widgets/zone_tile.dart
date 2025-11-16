import 'package:flutter/material.dart';

class ZoneTile extends StatelessWidget {
  final String zoneName;
  final bool selected;
  final VoidCallback onTap;

  const ZoneTile({
    Key? key,
    required this.zoneName,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(zoneName),
      trailing: selected
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.radio_button_unchecked),
      onTap: onTap,
    );
  }
}
