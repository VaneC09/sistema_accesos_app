// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : authorization_detail_screen.dart
// Módulo    : features/visit_authorization/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Detalle de solicitud para autorizar — RF-019, RF-020
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/primary_button_widget.dart';
import '../../bloc/visit_authorization_bloc.dart';
import '../../data/authorization_model.dart';
import '../dialogs/confirm_authorization_dialog.dart';

class AuthorizationDetailScreen extends StatelessWidget {
  final AuthorizationModel solicitud;

  const AuthorizationDetailScreen({
    super.key,
    required this.solicitud,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<VisitAuthorizationBloc, VisitAuthorizationState>(
      listener: (context, state) {
        if (state is AutorizacionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.mensaje),
              backgroundColor: AppColors.successGreen,
            ),
          );
          Navigator.pop(context);
        } else if (state is VisitAuthorizationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.mensaje),
              backgroundColor: AppColors.actionRed,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.baseSurface,
        appBar: AppBar(
          backgroundColor: AppColors.primaryCoral,
          title: const Text(
            'Detalle de solicitud',
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
        body: BlocBuilder<VisitAuthorizationBloc, VisitAuthorizationState>(
          builder: (context, state) {
            if (state is VisitAuthorizationLoading) {
              return const LoadingWidget(mensaje: 'Procesando...');
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.paddingPantalla),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tipo de visita
                  _InfoCard(
                    titulo: 'Información de la visita',
                    children: [
                      _InfoRow(
                        icono: Icons.category_outlined,
                        label: 'Tipo',
                        valor: solicitud.tipoVisita,
                      ),
                      _InfoRow(
                        icono: Icons.person_outline_rounded,
                        label: 'Solicitante',
                        valor: solicitud.nombreAnfitrion,
                      ),
                      _InfoRow(
                        icono: Icons.location_on_outlined,
                        label: 'Destino',
                        valor: solicitud.lugarDestino,
                      ),
                      _InfoRow(
                        icono: Icons.calendar_today_outlined,
                        label: 'Fecha',
                        valor: _formatearFecha(solicitud.fechaVisita),
                      ),
                      _InfoRow(
                        icono: Icons.notes_rounded,
                        label: 'Motivo',
                        valor: solicitud.motivoVisita,
                      ),
                      _InfoRow(
                        icono: Icons.timer_outlined,
                        label: 'Tolerancia',
                        valor:
                        '${solicitud.toleranciaAntes} min antes / ${solicitud.toleranciaDespues} min después',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Visitantes
                  _InfoCard(
                    titulo: 'Visitante(s)',
                    children: solicitud.visitantes
                        .map((v) => _InfoRow(
                      icono: Icons.person_outline_rounded,
                      label: v.nombre,
                      valor: v.correo,
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Botones de acción
                  PrimaryButtonWidget(
                    texto: AppStrings.botonAutorizar,
                    icono: Icons.check_circle_outline_rounded,
                    onPressed: () async {
                      final resultado =
                      await ConfirmAuthorizationDialog.mostrar(
                        context,
                        AccionAutorizacion.autorizar,
                      );
                      if (resultado != null && context.mounted) {
                        context.read<VisitAuthorizationBloc>().add(
                          AutorizarSolicitud(
                            idSolicitud: solicitud.idSolicitud,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Botón rechazar
                  SizedBox(
                    height: AppSpacing.alturaBoton,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final motivo =
                        await ConfirmAuthorizationDialog.mostrar(
                          context,
                          AccionAutorizacion.rechazar,
                        );
                        if (motivo != null && context.mounted) {
                          context.read<VisitAuthorizationBloc>().add(
                            RechazarSolicitud(
                              idSolicitud: solicitud.idSolicitud,
                              motivo: motivo,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.actionRed,
                        foregroundColor: AppColors.baseSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMedium,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text(AppStrings.botonRechazar),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoCard extends StatelessWidget {
  final String titulo;
  final List<Widget> children;

  const _InfoCard({
    required this.titulo,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.deepNavy,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;

  const _InfoRow({
    required this.icono,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18, color: AppColors.neutralGrey),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.steelBlue,
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onyxGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}