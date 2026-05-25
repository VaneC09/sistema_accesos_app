// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : home_screen.dart
// Módulo    : features/auth/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Pantalla principal con menú según rol del usuario
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth_bloc.dart';
import '../../presentation/dialogs/logout_dialog.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/nueva_solicitud_wrapper.dart';
import '../../../visit_request/presentation/screens/mis_solicitudes_screen.dart';
import '../../../visit_authorization/presentation/screens/autorizaciones_screen.dart';
import '../../../access_control/presentation/screens/qr_scanner_screen.dart';
import '../../../access_control/presentation/screens/visitas_hoy_screen.dart';

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
            MaterialPageRoute(
              builder: (_) => const _LoginRedirect(),
            ),
                (route) => false,
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return _buildHome(context, state);
          }
          return const SizedBox.shrink();
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
            icon: const Icon(
              Icons.logout_rounded,
              color: AppColors.baseSurface,
            ),
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
              // Chip de rol
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
              MaterialPageRoute(
                builder: (_) => NuevaSolicitudWrapper(),
              ),
            ),
          ),
          _MenuCard(
            icono: Icons.list_alt_rounded,
            titulo: AppStrings.menuMisSolicitudes,
            color: AppColors.headingDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MisSolicitudesScreen(),
              ),
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
              MaterialPageRoute(
                builder: (_) => NuevaSolicitudWrapper(),
              ),
            ),
          ),
          _MenuCard(
            icono: Icons.list_alt_rounded,
            titulo: AppStrings.menuMisSolicitudes,
            color: AppColors.headingDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MisSolicitudesScreen(),
              ),
            ),
          ),
          _MenuCard(
            icono: Icons.pending_actions_rounded,
            titulo: AppStrings.menuAutorizarVisitas,
            color: AppColors.successGreen,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AutorizacionesScreen(),
              ),
            ),
          ),
          _MenuCard(
            icono: Icons.notifications_outlined,
            titulo: AppStrings.menuNotificaciones,
            color: AppColors.headingSky,
            onTap: () {},
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
              MaterialPageRoute(
                builder: (_) => const QrScannerScreen(),
              ),
            ),
          ),
          _MenuCard(
            icono: Icons.list_alt_rounded,
            titulo: AppStrings.menuVisitasHoy,
            color: AppColors.headingDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const VisitasHoyScreen(),
              ),
            ),
          ),
          _MenuCard(
            icono: Icons.edit_note_rounded,
            titulo: AppStrings.menuRegistroManual,
            color: AppColors.headingSky,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const QrScannerScreen(),
              ),
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

class _LoginRedirect extends StatelessWidget {
  const _LoginRedirect();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryCoral,
        ),
      ),
    );
  }
}

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