import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/reading_state.dart';

import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReadingState(),
      child: MaterialApp(
        title: 'Tiba7',
        theme: ThemeData(
          // Primary color palette matching the logo (Deep Blue / Indigo & Vibrant Orange/Red)
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E3A8A), // Deep Blue
            secondary: const Color(0xFFEA580C), // Vibrant Orange
            surface: const Color(0xFFF8FAFC), // Off-white clean background
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor:
                Colors.transparent, // Transparent to allow gradient background
            foregroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 4,
            shadowColor: const Color(0xFF1E3A8A).withValues(alpha: 0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
