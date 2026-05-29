// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : main.dart
// Módulo    : root
// Autor     : Omega Company
// Fecha     : 2026-05-29
// Versión   : 1.2.0
// Descripción: El polling de notificaciones solo se activa para roles con
//              token Sanctum real (solicitante / autorizador).
//              El vigilante usa 'vigilante-local' y NO tiene acceso a
//              /notificaciones (requiere auth:sanctum).
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
import 'features/notifications/data/notification_model.dart';
import 'features/notifications/data/notification_service.dart';
import 'features/visit_confirmation/presentation/screens/visit_confirmation_screen.dart';

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
      child: const _AppListener(),
    );
  }
}

// =============================================================================
// _AppListener — controla el polling según el rol del usuario autenticado
// =============================================================================

class _AppListener extends StatefulWidget {
  const _AppListener();

  @override
  State<_AppListener> createState() => _AppListenerState();
}

class _AppListenerState extends State<_AppListener> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    NotificationService.instancia.onNotificacionTocada =
        _manejarToqueNotificacion;
  }

  /// Solo solicitante y autorizador tienen token Sanctum válido.
  /// El vigilante guarda 'vigilante-local' — el endpoint /notificaciones
  /// requiere auth:sanctum y devuelve 401 con ese token.
  bool _rolUsaNotificaciones(String rol) => rol != 'vigilante';

  void _manejarCambioAuth(BuildContext context, AuthState authState) {
    if (authState is AuthAuthenticated) {
      if (_rolUsaNotificaciones(authState.rol)) {
        // Solicitante o autorizador → arrancar polling
        context.read<NotificationBloc>().add(
          const IniciarPollingNotificaciones(
            intervalo: Duration(seconds: 15),
          ),
        );
      } else {
        // Vigilante → asegurarse de que el polling esté detenido
        context.read<NotificationBloc>().add(DetenerPollingNotificaciones());
      }
    } else if (authState is AuthUnauthenticated) {
      // Cierre de sesión → detener polling y limpiar estado
      context.read<NotificationBloc>()
        ..add(DetenerPollingNotificaciones())
        ..add(LimpiarNotificaciones());
    }
  }

  void _manejarToqueNotificacion(NotificationModel notificacion) {
    final nav = _navigatorKey.currentState;
    if (nav == null) return;

    if (notificacion.tipo == TipoNotificacion.visitanteIngreso ||
        notificacion.tipo == TipoNotificacion.solicitudExtension ||
        notificacion.tipo == TipoNotificacion.qrExpiradoTolerancia) {
      nav.push(MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<NotificationBloc>(),
          child: const VisitConfirmationScreen(),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: _manejarCambioAuth,
      child: MaterialApp(
        title: 'Sistema de Accesos ITT',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        navigatorKey: _navigatorKey,
        home: const _SplashScreen(),
      ),
    );
  }
}

// =============================================================================
// SplashScreen — sin cambios respecto a v1.0
// =============================================================================

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
    if (state is AuthAuthenticated) _irAHome();
    if (state is AuthUnauthenticated) _irALogin();
  }

  void _irAHome() => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => HomeScreen()),
        (route) => false,
  );

  void _irALogin() => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
  );

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) _irAHome();
        if (state is AuthUnauthenticated) _irALogin();
      },
      child: const Scaffold(
        backgroundColor: AppColors.baseSurface,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryCoral),
        ),
      ),
    );
  }
}