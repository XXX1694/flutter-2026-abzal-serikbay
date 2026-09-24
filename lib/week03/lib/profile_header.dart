import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String university;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.university,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Image.asset('assets/images/profile.png', width: 120, height: 120),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            name,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 24,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Text(university, style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
