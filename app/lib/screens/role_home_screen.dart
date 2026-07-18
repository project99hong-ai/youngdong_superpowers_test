import 'package:flutter/material.dart';

import '../models/demo_state.dart';

class RoleHomeScreen extends StatelessWidget {
  const RoleHomeScreen({
    required this.role,
    required this.onReset,
    super.key,
  });

  final UserRole role;
  final Future<void> Function() onReset;

  @override
  Widget build(BuildContext context) {
    final roleName = role == UserRole.child ? '자녀' : '시니어';

    return Scaffold(
      key: Key('role-home-${role.name}'),
      appBar: AppBar(title: const Text('똑똑용돈')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$roleName 홈',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              key: const Key('role-home-reset-button'),
              onPressed: onReset,
              child: const Text('역할 다시 선택'),
            ),
          ],
        ),
      ),
    );
  }
}
