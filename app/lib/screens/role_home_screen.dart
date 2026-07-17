import 'package:flutter/material.dart';

import '../models/demo_state.dart';

class RoleHomeScreen extends StatelessWidget {
  const RoleHomeScreen({
    required this.role,
    required this.onReset,
    super.key,
  });

  final UserRole role;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final roleName = role == UserRole.child ? '자녀' : '시니어';

    return Scaffold(
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
              onPressed: onReset,
              child: const Text('역할 다시 선택'),
            ),
          ],
        ),
      ),
    );
  }
}
