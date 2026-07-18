import 'package:flutter/material.dart';

import 'controllers/demo_controller.dart';
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
  late final DemoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DemoController(repository: widget.repository);
    _controller.addListener(_onControllerChanged);
    _controller.load();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_controller.status) {
      case DemoStatus.loading:
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(key: Key('demo-loading-indicator')),
          ),
        );
      case DemoStatus.error:
        return Scaffold(
          body: Center(
            child: Column(
              key: const Key('demo-error-state'),
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('데모 상태를 불러오지 못했어요.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  key: const Key('demo-retry-button'),
                  onPressed: _controller.load,
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        );
      case DemoStatus.ready:
        final role = _controller.selectedRole;
        if (role == null) {
          return RoleSelectScreen(onRoleSelected: _controller.selectRole);
        }
        return RoleHomeScreen(role: role, onReset: _controller.resetRole);
    }
  }
}
