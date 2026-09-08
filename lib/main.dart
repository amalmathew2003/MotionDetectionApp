import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/background_service.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  await setupNotificationChannel();
  await initializeService();
  runApp(const MotionGuardApp());
}

class MotionGuardApp extends StatelessWidget {
  const MotionGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motion Guard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF00D4AA),
        ),
      ),
      home: const MainShell(),
    );
  }
}
