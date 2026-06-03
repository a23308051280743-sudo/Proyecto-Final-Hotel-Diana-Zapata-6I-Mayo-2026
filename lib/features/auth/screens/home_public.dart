import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel/core/theme/app_theme.dart';

class HomePublic extends StatelessWidget {
  const HomePublic({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo centrado arriba
              const Text(
                'H',
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                  color: AppTheme.primaryRed,
                ),
              ),
              const Text(
                'HOTEL',
                style: TextStyle(
                  fontSize: 24,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textDark,
                ),
              ),
              const Text(
                'LUXURY MOONSEA',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 60),
              // Botones rojos
              ElevatedButton(
                onPressed: () => context.push('/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'REGÍSTRATE',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'INICIAR SESIÓN',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkRed,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'ADMINISTRADOR',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
