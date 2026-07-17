import 'package:flutter/material.dart';

class TtokttokAllowanceApp extends StatelessWidget {
  const TtokttokAllowanceApp({super.key});

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
      home: const Scaffold(
        body: Center(
          child: Text('똑똑용돈 MVP'),
        ),
      ),
    );
  }
}
