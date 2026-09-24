import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: colorScheme.outline)),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(value, style: TextStyle(color: colorScheme.onSurface)),
          ),
        ],
      ),
    );
  }
}
