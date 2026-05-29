// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : notifications_screen.dart
// Módulo    : features/notifications/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-29
// Versión   : 1.1.0
// Descripción: Listado de notificaciones — RF-023
//
// Cambios v1.1:
//  - Usa el NotificationBloc GLOBAL (context.read) en lugar de crear uno local.
//    Así el badge del AppBar y esta pantalla comparten el mismo estado.
//  - Al abrir la pantalla dispara CargarNotificaciones para refrescar.
//  - Botón "Marcar todas leídas" en AppBar.
//  - onTap en notificaciones accionables navega a la pantalla correcta:
//      · visitante_ingreso      → VisitConfirmationScreen
//      · solicitud_extension    → VisitConfirmationScreen (el diálogo se abre solo)
//      · qr_expirado_tolerancia → VisitConfirmationScreen
//      · solicitud_autorizada   → VisitDetailScreen
//  - El BlocListener reacciona a NuevaNotificacionRecibida para actualizar
//    la lista en tiempo real mientras el usuario está en esta pantalla.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/loading_widget.dart';
import 'package:sistema_accesos_app/core/widgets/error_widget.dart';
import '../../bloc/notification_bloc.dart';
import '../../data/notification_model.dart';
import '../../../visit_confirmation/presentation/screens/visit_confirmation_screen.dart';
import '../../../visit_request/presentation/screens/visit_detail_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Usamos el bloc GLOBAL que ya vive en el árbol (provisto en main.dart).
    // Al entrar a la pantalla refrescamos la lista.
    context.read<NotificationBloc>().add(CargarNotificaciones());
    return const _NotificationsView();
  }
}

// =============================================================================
// Vista
// =============================================================================

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseSurface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryCoral,
        title: const Text(
          'Notificaciones',
          style: TextStyle(color: AppColors.baseSurface),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.baseSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Marcar todas como leídas
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              final hayNoLeidas = _contarNoLeidas(state) > 0;
              if (!hayNoLeidas) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Marcar todas como leídas',
                icon: const Icon(Icons.done_all_rounded,
                    color: AppColors.baseSurface),
                onPressed: () {
                  context.read<NotificationBloc>().add(MarcarTodasLeidas());
                },
              );
            },
          ),
          // Refrescar
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.baseSurface),
            onPressed: () {
              context.read<NotificationBloc>().add(CargarNotificaciones());
            },
          ),
        ],
      ),

      // BlocListener para reaccionar a notificaciones accionables que lleguen
      // mientras el usuario tiene esta pantalla abierta.
      body: BlocListener<NotificationBloc, NotificationState>(
        listener: (context, state) {
          // Si llega una notificación accionable en tiempo real mientras el
          // usuario está aquí, la lista ya se actualizará vía BlocBuilder.
          // No necesitamos navegar — el usuario ya está en la pantalla correcta
          // para decidir qué hacer.
        },
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const LoadingWidget(mensaje: 'Cargando notificaciones...');
            }

            if (state is NotificationError) {
              return ErrorMessageWidget(
                mensaje: state.mensaje,
                onReintentar: () {
                  context.read<NotificationBloc>().add(CargarNotificaciones());
                },
              );
            }

            // Tanto NotificacionesLoaded como NuevaNotificacionRecibida
            // tienen la lista de notificaciones — extraemos con el helper.
            final notificaciones = _extraerLista(state);

            if (notificaciones.isNotEmpty) {
              return RefreshIndicator(
                color: AppColors.primaryCoral,
                onRefresh: () async {
                  context.read<NotificationBloc>().add(CargarNotificaciones());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: notificaciones.length,
                  itemBuilder: (context, index) {
                    final notificacion = notificaciones[index];
                    return _NotificationCard(
                      notificacion: notificacion,
                      onTap: () => _manejarToque(context, notificacion),
                    );
                  },
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.primaryCoral,
              onRefresh: () async {
                context.read<NotificationBloc>().add(CargarNotificaciones());
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [ //  Agregamos 'const' aquí para los hijos estáticos
                  SizedBox(height: 160),
                  _EmptyNotifications(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  List<NotificationModel> _extraerLista(NotificationState state) {
    if (state is NotificacionesLoaded) return state.notificaciones;
    if (state is NuevaNotificacionRecibida) return state.todasLasNotificaciones;
    return [];
  }

  int _contarNoLeidas(NotificationState state) {
    if (state is NotificacionesLoaded) return state.noLeidas;
    if (state is NuevaNotificacionRecibida) return state.noLeidas;
    return 0;
  }

  /// Marca como leída y navega a la pantalla correspondiente según el tipo.
  void _manejarToque(BuildContext context, NotificationModel notificacion) {
    // 1. Marcar como leída (persiste en backend vía MarcarNotificacionLeida)
    if (!notificacion.leida) {
      context.read<NotificationBloc>().add(
        MarcarNotificacionLeida(idNotificacion: notificacion.id),
      );
    }

    // 2. Navegar según tipo
    switch (notificacion.tipo) {
      case TipoNotificacion.visitanteIngreso:
      case TipoNotificacion.visitanteSalida:
      case TipoNotificacion.solicitudExtension:
      case TipoNotificacion.qrExpiradoTolerancia:
      case TipoNotificacion.permanenciaExcedida:
      // Ir a visitas activas — el BlocListener de VisitConfirmationScreen
      // abrirá el diálogo de extensión si corresponde.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<NotificationBloc>(),
              child: const VisitConfirmationScreen(),
            ),
          ),
        );
        break;

      case TipoNotificacion.solicitudAutorizada:
      case TipoNotificacion.solicitudRechazada:
      case TipoNotificacion.solicitudCancelada:
      case TipoNotificacion.qrExtendido:
      // Ir al detalle de la solicitud si tenemos el ID
        if (notificacion.idSolicitud != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VisitDetailScreen(
                idSolicitud: notificacion.idSolicitud!,
              ),
            ),
          );
        }
        break;

      case TipoNotificacion.visitanteLlegadaTarde:
      case TipoNotificacion.nuevaSolicitudPendiente:
      // Sin navegación especial — solo marcar leída
        break;
    }
  }
}

// =============================================================================
// Card de notificación — igual que v1 + indicador de accionable
// =============================================================================

class _NotificationCard extends StatelessWidget {
  final NotificationModel notificacion;
  final VoidCallback? onTap;

  const _NotificationCard({
    required this.notificacion,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorPorTipo(notificacion.tipo);
    final icono = _iconoPorTipo(notificacion.tipo);
    final esAccionable = notificacion.requiereAccion;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: notificacion.leida
              ? AppColors.baseSurface
              : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(
            color: notificacion.leida
                ? AppColors.surface
                : color.withOpacity(0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.surface,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícono circular
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icono, color: color, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),

            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título + chip "Acción requerida"
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notificacion.titulo,
                          style: TextStyle(
                            fontWeight: notificacion.leida
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: AppColors.deepNavy,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (esAccionable && !notificacion.leida) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusPill),
                          ),
                          child: Text(
                            'Acción',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  Text(
                    notificacion.mensaje,
                    style: const TextStyle(
                      color: AppColors.neutralGrey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Fecha + chevron si es accionable
                  Row(
                    children: [
                      Text(
                        _formatearFecha(notificacion.fecha),
                        style: const TextStyle(
                          color: AppColors.steelBlue,
                          fontSize: 11,
                        ),
                      ),
                      if (esAccionable) ...[
                        const Spacer(),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: color,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Punto de no leída
            if (!notificacion.leida) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Helpers de ícono y color (idénticos a v1) ────────────────────────────

  IconData _iconoPorTipo(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.solicitudAutorizada:
        return Icons.check_circle_outline_rounded;
      case TipoNotificacion.solicitudRechazada:
      case TipoNotificacion.solicitudCancelada:
        return Icons.cancel_outlined;
      case TipoNotificacion.visitanteIngreso:
        return Icons.login_rounded;
      case TipoNotificacion.visitanteSalida:
        return Icons.logout_rounded;
      case TipoNotificacion.visitanteLlegadaTarde:
      case TipoNotificacion.qrExpiradoTolerancia:
        return Icons.access_time_rounded;
      case TipoNotificacion.permanenciaExcedida:
        return Icons.warning_amber_rounded;
      case TipoNotificacion.qrExtendido:
        return Icons.more_time_rounded;
      case TipoNotificacion.solicitudExtension:
        return Icons.timer_outlined;
      case TipoNotificacion.nuevaSolicitudPendiente:
        return Icons.notifications_rounded;
    }
  }

  Color _colorPorTipo(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.solicitudAutorizada:
      case TipoNotificacion.visitanteIngreso:
      case TipoNotificacion.visitanteSalida:
      case TipoNotificacion.qrExtendido:
        return AppColors.successGreen;
      case TipoNotificacion.solicitudRechazada:
      case TipoNotificacion.solicitudCancelada:
      case TipoNotificacion.visitanteLlegadaTarde:
      case TipoNotificacion.permanenciaExcedida:
        return AppColors.actionRed;
      case TipoNotificacion.qrExpiradoTolerancia:
      case TipoNotificacion.solicitudExtension:
        return AppColors.warningOrange;
      case TipoNotificacion.nuevaSolicitudPendiente:
        return AppColors.primaryCoral;
    }
  }

  String _formatearFecha(DateTime fecha) {
    final dia    = fecha.day.toString().padLeft(2, '0');
    final mes    = fecha.month.toString().padLeft(2, '0');
    final anio   = fecha.year.toString();
    final hora   = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$anio $hora:$minuto';
  }
}

// =============================================================================
// Estado vacío — sin cambios vs v1
// =============================================================================

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.notifications_none_rounded,
          size: 72,
          color: AppColors.headingSky,
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'No tienes notificaciones',
          style: TextStyle(color: AppColors.neutralGrey, fontSize: 16),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Aquí aparecerán las alertas\nde tus solicitudes de visita',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.neutralGrey, fontSize: 13),
        ),
      ],
    );
  }
}