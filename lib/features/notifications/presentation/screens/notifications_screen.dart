// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : notifications_screen.dart
// Módulo    : features/notifications/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Pantalla de notificaciones reales — RF-023
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/loading_widget.dart';
import 'package:sistema_accesos_app/core/widgets/error_widget.dart';
import '../../bloc/notification_bloc.dart';
import '../../data/notification_model.dart';
import '../../data/notification_repository.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationBloc(
        repository: NotificationRepository(),
      )..add(CargarNotificaciones()),
      child: const _NotificationsView(),
    );
  }
}

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
          style: TextStyle(
            color: AppColors.baseSurface,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.baseSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.baseSurface,
            ),
            onPressed: () {
              context.read<NotificationBloc>().add(CargarNotificaciones());
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const LoadingWidget(
              mensaje: 'Cargando notificaciones...',
            );
          }

          if (state is NotificationError) {
            return ErrorMessageWidget(
              mensaje: state.mensaje,
              onReintentar: () {
                context.read<NotificationBloc>().add(CargarNotificaciones());
              },
            );
          }

          if (state is NotificacionesLoaded &&
              state.notificaciones.isNotEmpty) {
            return RefreshIndicator(
              color: AppColors.primaryCoral,
              onRefresh: () async {
                context.read<NotificationBloc>().add(CargarNotificaciones());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: state.notificaciones.length,
                itemBuilder: (context, index) {
                  final notificacion = state.notificaciones[index];

                  return _NotificationCard(
                    notificacion: notificacion,
                    onTap: () {
                      context.read<NotificationBloc>().add(
                        MarcarComoLeida(
                          idNotificacion: notificacion.id,
                        ),
                      );
                    },
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
              children: const [
                SizedBox(height: 160),
                _EmptyNotifications(),
              ],
            ),
          );
        },
      ),
    );
  }
}

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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(
          bottom: AppSpacing.sm,
        ),
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: notificacion.leida
              ? AppColors.baseSurface
              : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(
            AppSpacing.radiusMedium,
          ),
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
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(
                icono,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(
              width: AppSpacing.md,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notificacion.titulo,
                    style: TextStyle(
                      fontWeight: notificacion.leida
                          ? FontWeight.w500
                          : FontWeight.w700,
                      color: AppColors.deepNavy,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(
                    height: AppSpacing.xs,
                  ),
                  Text(
                    notificacion.mensaje,
                    style: const TextStyle(
                      color: AppColors.neutralGrey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(
                    height: AppSpacing.sm,
                  ),
                  Text(
                    _formatearFecha(notificacion.fecha),
                    style: const TextStyle(
                      color: AppColors.steelBlue,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (!notificacion.leida)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconoPorTipo(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.solicitudAutorizada:
        return Icons.check_circle_outline_rounded;

      case TipoNotificacion.solicitudRechazada:
      case TipoNotificacion.solicitudCancelada:
        return Icons.cancel_outlined;

      case TipoNotificacion.visitanteIngreso:
        return Icons.login_rounded;

      case TipoNotificacion.visitanteLlegadaTarde:
        return Icons.access_time_rounded;

      case TipoNotificacion.permanenciaExcedida:
        return Icons.warning_amber_rounded;

      case TipoNotificacion.qrExtendido:
        return Icons.qr_code_2_rounded;

      case TipoNotificacion.nuevaSolicitudPendiente:
        return Icons.notifications_rounded;
    }
  }

  Color _colorPorTipo(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.solicitudAutorizada:
      case TipoNotificacion.visitanteIngreso:
      case TipoNotificacion.qrExtendido:
        return AppColors.successGreen;

      case TipoNotificacion.solicitudRechazada:
      case TipoNotificacion.solicitudCancelada:
      case TipoNotificacion.visitanteLlegadaTarde:
      case TipoNotificacion.permanenciaExcedida:
        return AppColors.actionRed;

      case TipoNotificacion.nuevaSolicitudPendiente:
        return AppColors.primaryCoral;
    }
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();

    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$anio $hora:$minuto';
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.notifications_none_rounded,
          size: 72,
          color: AppColors.headingSky,
        ),
        const SizedBox(
          height: AppSpacing.md,
        ),
        const Text(
          'No tienes notificaciones',
          style: TextStyle(
            color: AppColors.neutralGrey,
            fontSize: 16,
          ),
        ),
        const SizedBox(
          height: AppSpacing.sm,
        ),
        const Text(
          'Aquí aparecerán las alertas\nde tus solicitudes de visita',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.neutralGrey,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}