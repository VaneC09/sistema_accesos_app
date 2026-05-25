// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : qr_detail_screen.dart
// Módulo    : features/qr_generation/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Pantalla de detalle y envío de QR — RF-021, RF-036, RF-038
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../qr_extension/presentation/dialogs/extend_qr_dialog.dart';
import '../../bloc/qr_generation_bloc.dart';
import '../../data/qr_generation_repository.dart';
import '../dialogs/send_qr_dialog.dart';
import '../widgets/qr_actions_widget.dart';
import '../widgets/qr_display_widget.dart';

class QrDetailScreen extends StatelessWidget {
  final int idSolicitud;

  const QrDetailScreen({super.key, required this.idSolicitud});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QrGenerationBloc(
        repository: QrGenerationRepository(),
      )..add(CargarQrSolicitud(idSolicitud: idSolicitud)),
      child: _QrDetailView(idSolicitud: idSolicitud),
    );
  }
}

class _QrDetailView extends StatelessWidget {
  final int idSolicitud;

  const _QrDetailView({required this.idSolicitud});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseSurface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryCoral,
        title: const Text(
          'Pase QR',
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
      body: BlocConsumer<QrGenerationBloc, QrGenerationState>(
        listener: (context, state) {
          if (state is QrActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: AppColors.successGreen,
              ),
            );
            context.read<QrGenerationBloc>().add(
              CargarQrSolicitud(idSolicitud: idSolicitud),
            );
          } else if (state is QrGenerationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: AppColors.actionRed,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is QrGenerationLoading) {
            return const LoadingWidget(mensaje: 'Cargando QR...');
          }

          if (state is QrGenerationError) {
            return ErrorMessageWidget(
              mensaje: state.mensaje,
              onReintentar: () {
                context.read<QrGenerationBloc>().add(
                  CargarQrSolicitud(idSolicitud: idSolicitud),
                );
              },
            );
          }

          if (state is QrLoaded) {
            if (state.qrList.isEmpty) {
              return const Center(
                child: Text(
                  'No hay QR disponible para esta solicitud',
                  style: TextStyle(color: AppColors.neutralGrey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.paddingPantalla),
              itemCount: state.qrList.length,
              itemBuilder: (context, index) {
                final qr = state.qrList[index];
                return Column(
                  children: [
                    QrDisplayWidget(qr: qr),
                    const SizedBox(height: AppSpacing.lg),
                    QrActionsWidget(
                      qr: qr,
                      cargando: state is QrGenerationLoading,
                      onEnviar: () async {
                        final confirmar = await SendQrDialog.mostrar(context);
                        if (confirmar == true && context.mounted) {
                          context.read<QrGenerationBloc>().add(
                            EnviarQrVisitante(idSolicitud: idSolicitud),
                          );
                        }
                      },
                      onReenviar: () async {
                        final confirmar = await SendQrDialog.mostrar(context);
                        if (confirmar == true && context.mounted) {
                          context.read<QrGenerationBloc>().add(
                            ReenviarQrVisitante(
                              idSolicitud: idSolicitud,
                              qr: qr,
                            ),
                          );
                        }
                      },
                      onExtender: () async {
                        await ExtendQrDialog.mostrar(context, idSolicitud);
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}