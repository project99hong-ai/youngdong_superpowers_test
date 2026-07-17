import 'package:flutter/material.dart';

import 'models/demo_state.dart';
import 'repositories/demo_repository.dart';
import 'screens/role_home_screen.dart';
import 'screens/role_select_screen.dart';

class TtokttokAllowanceApp extends StatelessWidget {
  const TtokttokAllowanceApp({
    required this.repository,
    super.key,
  });

  final DemoRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '똑똑용돈',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F6F73),
        ),
        useMaterial3: true,
      ),
      home: _AppStateCoordinator(repository: repository),
    );
  }
}

class _AppStateCoordinator extends StatefulWidget {
  const _AppStateCoordinator({required this.repository});

  final DemoRepository repository;

  @override
  State<_AppStateCoordinator> createState() => _AppStateCoordinatorState();
}

class _AppStateCoordinatorState extends State<_AppStateCoordinator> {
  late Future<DemoState> _state;

  @override
  void initState() {
    super.initState();
    _state = widget.repository.loadState();
  }

  void _selectRole(UserRole role) {
    setState(() {
      _state = widget.repository.selectRole(role);
    });
  }

  void _resetRole() {
    setState(() {
      _state = widget.repository.resetDemo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DemoState>(
      future: _state,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data!.selectedRole;
        if (role == null) {
          return RoleSelectScreen(onRoleSelected: _selectRole);
        }

        return RoleHomeScreen(role: role, onReset: _resetRole);
      },
    );
  }
}
