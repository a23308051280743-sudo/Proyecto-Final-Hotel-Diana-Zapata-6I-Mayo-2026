import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulate a delay and then navigate
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        context.go('/home-public');
      }
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hotel, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Hotel App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
}
