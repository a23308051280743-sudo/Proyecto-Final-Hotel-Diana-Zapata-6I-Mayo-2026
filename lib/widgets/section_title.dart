import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Expanded(
            child: Divider(
              color: Theme.of(context).colorScheme.primary,
              thickness: 2,
              indent: 0,
            ),
          ),
        ],
      ),
    );
  }
}
