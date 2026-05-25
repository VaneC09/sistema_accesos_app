// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : visit_confirmation_screen.dart
// Módulo    : features/visit_confirmation/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Pantalla de confirmación de visita — RF-026, RF-051, RF-052
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import 'package:sistema_accesos_app/core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/primary_button_widget.dart';
import '../../bloc/visit_confirmation_bloc.dart';
import '../../data/confirmation_model.dart';
import '../../data/confirmation_repository.dart';

class VisitConfirmationScreen extends StatelessWidget {
  const VisitConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VisitConfirmationBloc(
        repository: ConfirmationRepository(),
      )..add(CargarVisitasActivas()),
      child: const _VisitConfirmationView(),
    );
  }
}

class _VisitConfirmationView extends StatelessWidget {
  const _VisitConfirmationView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseSurface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryCoral,
        title: const Text(
          'Visitas activas',
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
      body: BlocConsumer<VisitConfirmationBloc, VisitConfirmationState>(
        listener: (context, state) {
          if (state is ConfirmationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: AppColors.successGreen,
              ),
            );
            context
                .read<VisitConfirmationBloc>()
                .add(CargarVisitasActivas());
          } else if (state is VisitConfirmationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: AppColors.actionRed,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is VisitConfirmationLoading) {
            return const LoadingWidget(mensaje: 'Cargando visitas activas...');
          }

          if (state is VisitConfirmationError) {
            return ErrorMessageWidget(
              mensaje: state.mensaje,
              onReintentar: () {
                context
                    .read<VisitConfirmationBloc>()
                    .add(CargarVisitasActivas());
              },
            );
          }

          if (state is VisitasActivasLoaded) {
            if (state.visitas.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 72,
                      color: AppColors.headingSky,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'No hay visitas activas en este momento',
                      style: TextStyle(
                        color: AppColors.neutralGrey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: state.visitas.length,
              itemBuilder: (context, index) {
                return _VisitaActivaCard(visita: state.visitas[index]);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _VisitaActivaCard extends StatelessWidget {
  final ConfirmationModel visita;

  const _VisitaActivaCard({required this.visita});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.headingSky),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre visitante
          Text(
            visita.nombreVisitante,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.deepNavy,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Folio: ${visita.folio}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.neutralGrey,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Timeline de eventos
          _TimelineItem(
            icono: Icons.login_rounded,
            label: 'Llegada al campus',
            hora: visita.horaLlegadaCampus,
          ),
          _TimelineItem(
            icono: Icons.room_rounded,
            label: 'Llegada al área',
            hora: visita.horaLlegadaArea,
          ),
          _TimelineItem(
            icono: Icons.logout_rounded,
            label: 'Salida del área',
            hora: visita.horaSalidaArea,
          ),
          const SizedBox(height: AppSpacing.md),

          // Botones de acción
          if (visita.horaLlegadaArea == null) ...[
            PrimaryButtonWidget(
              texto: 'Confirmar llegada al área',
              icono: Icons.check_circle_outline_rounded,
              onPressed: () {
                context.read<VisitConfirmationBloc>().add(
                  ConfirmarLlegadaArea(
                    idSolicitud: visita.idSolicitud,
                  ),
                );
              },
            ),
          ] else if (visita.horaSalidaArea == null) ...[
            SizedBox(
              height: AppSpacing.alturaBoton,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<VisitConfirmationBloc>().add(
                    ConfirmarSalidaArea(
                      idSolicitud: visita.idSolicitud,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.headingDark,
                  foregroundColor: AppColors.baseSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Registrar salida del área'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final IconData icono;
  final String label;
  final DateTime? hora;

  const _TimelineItem({
    required this.icono,
    required this.label,
    this.hora,
  });

  @override
  Widget build(BuildContext context) {
    final registrado = hora != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            icono,
            size: 18,
            color: registrado ? AppColors.successGreen : AppColors.surface,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: registrado ? AppColors.onyxGrey : AppColors.neutralGrey,
            ),
          ),
          const Spacer(),
          Text(
            hora != null ? _formatearHora(hora!) : 'Pendiente',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: registrado ? AppColors.successGreen : AppColors.neutralGrey,
            ),
          ),
        ],
      ),
    );
  }

  String _formatearHora(DateTime hora) {
    return '${hora.hour}:${hora.minute.toString().padLeft(2, '0')}';
  }
}