import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'main_container.dart';
import 'my_records_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import 'my_records_detail_screen.dart';
import 'upload_document_screen.dart';
import 'share_history_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthLock',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4285F4)),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainContainer(),
        '/records': (context) => const MyRecordsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/records-detail': (context) => const MyRecordsDetailScreen(),
        '/upload-document': (context) => const UploadDocumentScreen(),
      },
      initialRoute: '/login',
    );
  }
}


