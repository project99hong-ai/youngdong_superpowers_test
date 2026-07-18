import 'package:flutter/material.dart';

import '../models/demo_state.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({
    required this.onRoleSelected,
    super.key,
  });

  final Future<void> Function(UserRole) onRoleSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('똑똑용돈')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '어떤 역할로 시작할까요?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                key: const Key('role-select-child-button'),
                onPressed: () => onRoleSelected(UserRole.child),
                child: const Text('자녀로 시작'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                key: const Key('role-select-senior-button'),
                onPressed: () => onRoleSelected(UserRole.senior),
                child: const Text('시니어로 시작'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
