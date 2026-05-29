// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : main.dart
// Módulo    : root
// Autor     : Omega Company
// Fecha     : 2026-05-29
// Versión   : 1.1.0
// Descripción: Arranca polling de notificaciones al autenticarse — RF-023
//
// Cambios v1.1:
//  - BlocListener<AuthBloc> inicia IniciarPollingNotificaciones al autenticarse
//    y dispara DetenerPollingNotificaciones + LimpiarNotificaciones al salir.
//  - NotificationService.instancia.onNotificacionTocada conecta con el
//    NotificationBloc para que los toques de notificación local naveguen
//    a la pantalla correcta.
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
        // NotificationBloc global — el polling lo arranca _AppListener
        // una vez que el usuario está autenticado.
        BlocProvider(
          create: (_) => NotificationBloc(),
        ),
      ],
      child: const _AppListener(),
    );
  }
}

/// Envuelve MaterialApp para poder escuchar AuthBloc y NotificationBloc
/// antes de que se construya cualquier ruta.
class _AppListener extends StatefulWidget {
  const _AppListener();

  @override
  State<_AppListener> createState() => _AppListenerState();
}

class _AppListenerState extends State<_AppListener> {
  /// Navegador global para navegar desde callbacks fuera del árbol de extension_dialog.dart
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    // Cuando el usuario toca una notificación local (incluso con la app en
    // background), el servicio llama este callback.
    NotificationService.instancia.onNotificacionTocada =
        _manejarToqueNotificacion;
  }

  void _manejarToqueNotificacion(NotificationModel notificacion) {
    final nav = _navigatorKey.currentState;
    if (nav == null) return;

    if (notificacion.tipo == TipoNotificacion.visitanteIngreso) {
      // Ir directamente a visitas activas
      nav.push(MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<NotificationBloc>(),
          child: const VisitConfirmationScreen(),
        ),
      ));
    } else if (notificacion.tipo == TipoNotificacion.solicitudExtension ||
        notificacion.tipo == TipoNotificacion.qrExpiradoTolerancia) {
      // También ir a visitas activas — el diálogo de extensión
      // se abre automáticamente cuando el BlocListener detecta el estado.
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
      listener: (context, authState) {
        if (authState is AuthAuthenticated) {
          // Usuario autenticado → arrancar polling
          context.read<NotificationBloc>().add(
            const IniciarPollingNotificaciones(
              intervalo: Duration(seconds: 15),
            ),
          );
        } else if (authState is AuthUnauthenticated) {
          // Sesión cerrada → detener polling y limpiar estado
          context.read<NotificationBloc>()
            ..add(DetenerPollingNotificaciones())
            ..add(LimpiarNotificaciones());
        }
      },
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
    if (state is AuthAuthenticated) {
      _irAHome();
    } else if (state is AuthUnauthenticated) {
      _irALogin();
    }
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