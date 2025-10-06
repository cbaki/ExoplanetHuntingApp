import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/loading_screen.dart';
import 'screens/planet_scan_screen.dart';

void main() {
  runApp(const PlanetHunterApp());
}

class PlanetHunterApp extends StatefulWidget {
  const PlanetHunterApp({super.key});

  @override
  State<PlanetHunterApp> createState() => _PlanetHunterAppState();
}

class _PlanetHunterAppState extends State<PlanetHunterApp> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    // 3 saniye yükleme simülasyonu
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gezegen Avı',
      theme: AppTheme.darkTheme,
      home: _isLoading ? const LoadingScreen() : const PlanetScanScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
