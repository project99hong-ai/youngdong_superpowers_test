import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/demo_state.dart';

class DemoStorageService {
  static const String _stateKey = 'ttokttok_demo_state_v1';

  Future<DemoState> loadState() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_stateKey);
    if (raw == null || raw.isEmpty) {
      return DemoState.initial();
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return DemoState.fromJson(decoded);
  }

  Future<void> saveState(DemoState state) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_stateKey, jsonEncode(state.toJson()));
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_stateKey);
  }
}
