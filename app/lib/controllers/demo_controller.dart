import 'package:flutter/foundation.dart';

import '../models/demo_state.dart';
import '../repositories/demo_repository.dart';

enum DemoStatus { loading, ready, error }

class DemoController extends ChangeNotifier {
  DemoController({required this.repository});

  final DemoRepository repository;

  DemoStatus _status = DemoStatus.loading;
  DemoState? _state;
  Object? _error;

  DemoStatus get status => _status;
  UserRole? get selectedRole => _state?.selectedRole;
  Object? get error => _error;

  Future<void> load() => _update(repository.loadState);

  Future<void> selectRole(UserRole role) =>
      _update(() => repository.selectRole(role));

  Future<void> resetRole() => _update(repository.resetDemo);

  Future<void> _update(Future<DemoState> Function() action) async {
    _status = DemoStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _state = await action();
      _status = DemoStatus.ready;
    } catch (error) {
      _state = null;
      _error = error;
      _status = DemoStatus.error;
    }
    notifyListeners();
  }
}
