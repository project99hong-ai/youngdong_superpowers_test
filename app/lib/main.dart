import 'package:flutter/material.dart';

import 'app.dart';
import 'repositories/demo_repository.dart';
import 'services/demo_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    TtokttokAllowanceApp(
      repository: LocalDemoRepository(DemoStorageService()),
    ),
  );
}
