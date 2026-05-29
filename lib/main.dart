// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : main.dart
// Módulo    : root
// Autor     : Omega Company
// Fecha     : 2026-05-29
// Versión   : 1.3.0
// Descripción: Polling de notificaciones según rol:
//              - solicitante / autorizador → /notificaciones (Sanctum)
//              - vigilante → /vigilante/notificaciones (teléfono local)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/config/app_config.dart';
import 'core/connection/api_client.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/access_control/presentation/screens/qr_scanner_screen.dart';
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

class _AppListener extends StatefulWidget {
  const _AppListener();

  @override
  State<_AppListener> createState() => _AppListenerState();
}

class _AppListenerState extends State<_AppListener> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  static const _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    NotificationService.instancia.onNotificacionTocada =
        _manejarToqueNotificacion;
  }

  bool _esEmpleado(AuthAuthenticated auth) => auth.rol != 'vigilante';

  Future<void> _manejarCambioAuth(
    BuildContext context,
    AuthState authState,
  ) async {
    final bloc = context.read<NotificationBloc>();

    if (authState is AuthAuthenticated) {
      if (_esEmpleado(authState)) {
        final token =
            await _storage.read(key: AppConfig.claveToken) ?? '';
        if (!context.mounted) return;

        if (token.isEmpty || token == 'vigilante-local') {
          bloc.add(DetenerPollingNotificaciones());
          return;
        }

        bloc.add(
          const IniciarPollingNotificaciones(
            intervalo: Duration(seconds: 15),
          ),
        );
      } else {
        final telefono =
            await _storage.read(key: AppConfig.claveTelefonoVigilante) ?? '';
        if (!context.mounted) return;

        if (telefono.isNotEmpty) {
          bloc.add(
            IniciarPollingVigilante(
              telefono: telefono,
              intervalo: const Duration(seconds: 15),
            ),
          );
        } else {
          bloc.add(DetenerPollingNotificaciones());
        }
      }
    } else if (authState is AuthUnauthenticated) {
      bloc
        ..add(DetenerPollingNotificaciones())
        ..add(LimpiarNotificaciones());
    }
  }

  void _manejarNotificacionRecibida(
    BuildContext context,
    NotificationModel notificacion,
  ) {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;

    if (auth.rol == 'vigilante' &&
        notificacion.tipo == TipoNotificacion.qrExtendido) {
      NotificationService.instancia.notificarQrExtendido(
        nombreVisitante: notificacion.nombreVisitante ?? 'Visitante',
        folio: notificacion.folio ?? '—',
        idNotificacion: int.tryParse(notificacion.id),
      );

      if (notificacion.id.isNotEmpty) {
        context.read<NotificationBloc>().add(
              MarcarNotificacionLeida(idNotificacion: notificacion.id),
            );
      }
    }
  }

  void _manejarToqueNotificacion(NotificationModel notificacion) {
    final nav = _navigatorKey.currentState;
    if (nav == null) return;

    if (notificacion.tipo == TipoNotificacion.qrExtendido) {
      nav.push(
        MaterialPageRoute(builder: (_) => const QrScannerScreen()),
      );
      return;
    }

    if (notificacion.tipo == TipoNotificacion.visitanteIngreso ||
        notificacion.tipo == TipoNotificacion.solicitudExtension ||
        notificacion.tipo == TipoNotificacion.qrExpiradoTolerancia) {
      nav.push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<NotificationBloc>(),
            child: const VisitConfirmationScreen(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: _manejarCambioAuth,
        ),
        BlocListener<NotificationBloc, NotificationState>(
          listener: (context, state) {
            if (state is NuevaNotificacionRecibida) {
              _manejarNotificacionRecibida(context, state.notificacion);
            }
          },
        ),
      ],
      child: MaterialApp(
        title: AppStrings.tituloApp,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        navigatorKey: _navigatorKey,
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
