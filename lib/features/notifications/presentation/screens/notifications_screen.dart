// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : notifications_screen.dart
// Módulo    : features/notifications/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Pantalla de notificaciones — RF-023
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../bloc/notification_bloc.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.baseSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificacionesLoaded && state.notificaciones.isNotEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: state.notificaciones.length,
              itemBuilder: (context, index) {
                final notif = state.notificaciones[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: notif.leida
                        ? AppColors.surface
                        : AppColors.headingSky.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    border: Border.all(color: AppColors.surface),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_rounded,
                        color: notif.leida
                            ? AppColors.neutralGrey
                            : AppColors.primaryCoral,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notif.titulo,
                              style: TextStyle(
                                fontWeight: notif.leida
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                                color: AppColors.deepNavy,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              notif.mensaje,
                              style: const TextStyle(
                                color: AppColors.neutralGrey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: 72,
                  color: AppColors.headingSky,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'No tienes notificaciones',
                  style: TextStyle(
                    color: AppColors.neutralGrey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Aquí aparecerán las alertas\nde tus solicitudes de visita',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.neutralGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}