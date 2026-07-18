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
  var _isDisposed = false;

  DemoStatus get status => _status;
  UserRole? get selectedRole => _state?.selectedRole;
  Object? get error => _error;

  Future<void> load() => _update(repository.loadState);

  Future<void> selectRole(UserRole role) =>
      _update(() => repository.selectRole(role));

  Future<void> resetRole() => _update(repository.resetDemo);

  Future<void> _update(Future<DemoState> Function() action) async {
    if (_isDisposed) {
      return;
    }

    _status = DemoStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final state = await action();
      if (_isDisposed) {
        return;
      }
      _state = state;
      _status = DemoStatus.ready;
    } catch (error) {
      if (_isDisposed) {
        return;
      }
      _state = null;
      _error = error;
      _status = DemoStatus.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
