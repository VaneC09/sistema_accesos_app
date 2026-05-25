// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : main.dart
// Módulo    : root
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Punto de entrada de la aplicación
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/connection/api_client.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/screens/home_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/notifications/bloc/notification_bloc.dart';
import 'features/notifications/data/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.instancia.inicializar();
  await NotificationService.instancia.inicializar();
  runApp(const SistemaAccesosApp());
}

class SistemaAccesosApp extends StatelessWidget {
  const SistemaAccesosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            repository: AuthRepository(),
          )..add(VerificarSesion()),
        ),
        BlocProvider(
          create: (_) => NotificationBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Sistema de Accesos ITT',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const _SplashScreen(),
      ),
    );
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificar();
  }

  Future<void> _verificar() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      _irAHome();
    } else if (state is AuthUnauthenticated) {
      _irALogin();
    }
    // Si aún está cargando espera el listener
  }

  void _irAHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
          (route) => false,
    );
  }

  void _irALogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _irAHome();
        } else if (state is AuthUnauthenticated) {
          _irALogin();
        }
      },
      child: const Scaffold(
        backgroundColor: AppColors.baseSurface,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryCoral,
          ),
        ),
      ),
    );
  }
}