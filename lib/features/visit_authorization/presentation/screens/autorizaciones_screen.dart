// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : autorizaciones_screen.dart
// Módulo    : features/visit_authorization/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Pantalla de solicitudes pendientes de autorización — RF-019
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/loading_widget.dart';
import 'package:sistema_accesos_app/core/widgets/error_widget.dart';
import '../../bloc/visit_authorization_bloc.dart';
import '../../data/authorization_repository.dart';
import '../widgets/authorization_card_widget.dart';
import 'authorization_detail_screen.dart';

class AutorizacionesScreen extends StatelessWidget {
  const AutorizacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VisitAuthorizationBloc(
        repository: AuthorizationRepository(),
      )..add(CargarPendientes()),
      child: const _AutorizacionesView(),
    );
  }
}

class _AutorizacionesView extends StatelessWidget {
  const _AutorizacionesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseSurface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryCoral,
        title: const Text(
          AppStrings.tituloAutorizaciones,
          style: TextStyle(color: AppColors.baseSurface),
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
              context.read<VisitAuthorizationBloc>().add(CargarPendientes());
            },
          ),
        ],
      ),
      body: BlocBuilder<VisitAuthorizationBloc, VisitAuthorizationState>(
        builder: (context, state) {
          if (state is VisitAuthorizationLoading) {
            return const LoadingWidget(
              mensaje: 'Cargando solicitudes pendientes...',
            );
          }

          if (state is VisitAuthorizationError) {
            return ErrorMessageWidget(
              mensaje: state.mensaje,
              onReintentar: () {
                context
                    .read<VisitAuthorizationBloc>()
                    .add(CargarPendientes());
              },
            );

          }


          if (state is PendientesLoaded) {
            if (state.pendientes.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 72,
                      color: AppColors.successGreen,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'No hay solicitudes pendientes',
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
              itemCount: state.pendientes.length,
              itemBuilder: (context, index) {
                return AuthorizationCardWidget(
                  solicitud: state.pendientes[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => VisitAuthorizationBloc(
                            repository: AuthorizationRepository(),
                          ),
                          child: AuthorizationDetailScreen(
                            solicitud: state.pendientes[index],
                          ),
                        ),
                      ),
                    ).then((_) {
                      context
                          .read<VisitAuthorizationBloc>()
                          .add(CargarPendientes());
                    });
                  },
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