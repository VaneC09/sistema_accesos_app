// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : home_screen.dart
// Módulo    : features/auth/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-25
// Versión   : 1.0.0
// Descripción: Pantalla principal con menú según rol del usuario
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth_bloc.dart';
import '../../data/auth_repository.dart';
import '../../presentation/dialogs/logout_dialog.dart';
import '../../presentation/screens/login_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/nueva_solicitud_wrapper.dart';
import '../../../visit_request/presentation/screens/mis_solicitudes_screen.dart';
import '../../../visit_request/presentation/screens/consulta_screen.dart';
import '../../../visit_authorization/presentation/screens/autorizaciones_screen.dart';
import '../../../access_control/bloc/access_control_bloc.dart';
import '../../../access_control/data/access_repository.dart';
import '../../../access_control/presentation/dialogs/manual_code_dialog.dart';
import '../../../access_control/presentation/screens/qr_scanner_screen.dart';
import '../../../access_control/presentation/screens/visitas_hoy_screen.dart';
import '../../../access_control/presentation/widgets/qr_result_widget.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const _LoginRedirect()),
                (route) => false,
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          // 1. Si la autenticación es exitosa, muestra el menú
          if (state is AuthAuthenticated) {
            return _buildHome(context, state);
          }

          // 2. Si ocurre un error, muestra el mensaje en pantalla para diagnóstico
          if (state is AuthError) {
            return Scaffold(
              backgroundColor: AppColors.baseSurface,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.paddingPantalla),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.actionRed, size: 64),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Error de Autenticación:\n${state.mensaje}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.actionRed, fontSize: 16),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(LogoutRequested());
                        },
                        child: const Text('Volver al Login'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // 3. Mientras procesa o carga, muestra el indicador visual
          return const Scaffold(
            backgroundColor: AppColors.baseSurface,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryCoral,
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildHome(BuildContext context, AuthAuthenticated state) {
    return Scaffold(
      backgroundColor: AppColors.baseSurface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryCoral,
        title: Text(
          'Bienvenido, ${state.nombre}',
          style: const TextStyle(
            color: AppColors.baseSurface,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.baseSurface),
            onPressed: () => _onLogoutPressed(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.paddingPantalla),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.headingSky,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Text(
                  _getRolLabel(state.rol),
                  style: const TextStyle(
                    color: AppColors.deepNavy,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppStrings.preguntaAccion,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  children: _getMenuItems(context, state.rol),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRolLabel(String rol) {
    switch (rol) {
      case 'empleado':
        return 'Empleado';
      case 'jefe':
        return 'Jefe de Área';
      case 'recursos_materiales':
        return 'Recursos Materiales';
      case 'vigilante':
        return 'Vigilante';
      default:
        return rol;
    }
  }

  List<Widget> _getMenuItems(BuildContext context, String rol) {
    switch (rol) {
      case 'empleado':
        return [
          _MenuCard(
            icono: Icons.add_circle_outline_rounded,
            titulo: AppStrings.menuNuevaSolicitud,
            color: AppColors.primaryCoral,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NuevaSolicitudWrapper()),
            ),
          ),
          _MenuCard(
            icono: Icons.list_alt_rounded,
            titulo: AppStrings.menuMisSolicitudes,
            color: AppColors.headingDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MisSolicitudesScreen()),
            ),
          ),
        ];

      case 'jefe':
      case 'recursos_materiales':
        return [
          _MenuCard(
            icono: Icons.add_circle_outline_rounded,
            titulo: AppStrings.menuNuevaSolicitud,
            color: AppColors.primaryCoral,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NuevaSolicitudWrapper()),
            ),
          ),
          _MenuCard(
            icono: Icons.list_alt_rounded,
            titulo: AppStrings.menuMisSolicitudes,
            color: AppColors.headingDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MisSolicitudesScreen()),
            ),
          ),
          _MenuCard(
            icono: Icons.pending_actions_rounded,
            titulo: AppStrings.menuAutorizarVisitas,
            color: AppColors.successGreen,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AutorizacionesScreen()),
            ),
          ),
          _MenuCard(
            icono: Icons.notifications_outlined,
            titulo: AppStrings.menuNotificaciones,
            color: AppColors.headingSky,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
        ];

      case 'vigilante':
        return [
          _MenuCard(
            icono: Icons.qr_code_scanner_rounded,
            titulo: AppStrings.menuEscanearQr,
            color: AppColors.primaryCoral,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QrScannerScreen()),
            ),
          ),
          _MenuCard(
            icono: Icons.list_alt_rounded,
            titulo: AppStrings.menuVisitasHoy,
            color: AppColors.headingDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VisitasHoyScreen()),
            ),
          ),
          _MenuCard(
            icono: Icons.edit_note_rounded,
            titulo: AppStrings.menuRegistroManual,
            color: AppColors.headingSky,
            onTap: () async {
              final codigo = await ManualCodeDialog.mostrar(context);
              if (codigo != null && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => AccessControlBloc(
                        repository: AccessRepository(),
                      ),
                      child: _RegistroManualScreen(codigo: codigo),
                    ),
                  ),
                );
              }
            },
          ),
          _MenuCard(
            icono: Icons.help_outline_rounded,
            titulo: 'Visita de Consulta',
            color: AppColors.warningOrange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ConsultaScreen()),
            ),
          ),
        ];

      default:
        return [];
    }
  }

  Future<void> _onLogoutPressed(BuildContext context) async {
    final confirmar = await LogoutDialog.mostrar(context);
    if (confirmar == true && context.mounted) {
      context.read<AuthBloc>().add(LogoutRequested());
    }
  }
}

// ── Login Redirect ─────────────────────────────────────────────────────────────
class _LoginRedirect extends StatefulWidget {
  const _LoginRedirect();

  @override
  State<_LoginRedirect> createState() => _LoginRedirectState();
}

class _LoginRedirectState extends State<_LoginRedirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => AuthBloc(repository: AuthRepository()),
            child: const LoginScreen(),
          ),
        ),
            (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primaryCoral),
      ),
    );
  }
}

// ── Registro Manual Screen ─────────────────────────────────────────────────────
class _RegistroManualScreen extends StatefulWidget {
  final String codigo;

  const _RegistroManualScreen({required this.codigo});

  @override
  State<_RegistroManualScreen> createState() => _RegistroManualScreenState();
}

class _RegistroManualScreenState extends State<_RegistroManualScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AccessControlBloc>().add(
      RegistroManual(
        codigoNumerico: widget.codigo,
        telefono: '',
        area: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseSurface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryCoral,
        title: const Text(
          'Registro manual',
          style: TextStyle(color: AppColors.baseSurface),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.baseSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<AccessControlBloc, AccessControlState>(
        builder: (context, state) {
          if (state is AccessControlLoading) {
            return const LoadingWidget(mensaje: 'Validando código...');
          }
          if (state is QrEscaneadoSuccess) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.paddingPantalla),
              child: QrResultWidget(
                resultado: state.resultado,
                onNuevoEscaneo: () => Navigator.pop(context),
              ),
            );
          }
          if (state is AccessControlError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.paddingPantalla),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.actionRed,
                      size: 72,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      state.mensaje,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.actionRed,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Volver'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const LoadingWidget(mensaje: 'Procesando...');
        },
      ),
    );
  }
}

// ── Menu Card ──────────────────────────────────────────────────────────────────
class _MenuCard extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icono,
    required this.titulo,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          border: Border.all(color: AppColors.surface),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: AppSpacing.iconoLarge, color: color),
            const SizedBox(height: AppSpacing.md),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.deepNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}