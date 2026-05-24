// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : visitas_hoy_screen.dart
// Módulo    : features/access_control/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Pantalla de visitas del día para vigilante — RF-025
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../bloc/access_control_bloc.dart';
import '../../data/access_repository.dart';
import '../widgets/visit_list_item_widget.dart';

class VisitasHoyScreen extends StatelessWidget {
  const VisitasHoyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String telefono = '';
    if (authState is AuthAuthenticated) {
      telefono = authState.nombre;
    }

    return BlocProvider(
      create: (_) => AccessControlBloc(
        repository: AccessRepository(),
      )..add(CargarVisitasHoy(telefono: telefono)),
      child: const _VisitasHoyView(),
    );
  }
}

class _VisitasHoyView extends StatelessWidget {
  const _VisitasHoyView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseSurface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryCoral,
        title: const Text(
          AppStrings.tituloVisitasHoy,
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
              final authState = context.read<AuthBloc>().state;
              String telefono = '';
              if (authState is AuthAuthenticated) {
                telefono = authState.nombre;
              }
              context.read<AccessControlBloc>().add(
                CargarVisitasHoy(telefono: telefono),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AccessControlBloc, AccessControlState>(
        builder: (context, state) {
          if (state is AccessControlLoading) {
            return const LoadingWidget(
              mensaje: 'Cargando visitas del día...',
            );
          }

          if (state is AccessControlError) {
            return ErrorMessageWidget(
              mensaje: state.mensaje,
              onReintentar: () {
                final authState = context.read<AuthBloc>().state;
                String telefono = '';
                if (authState is AuthAuthenticated) {
                  telefono = authState.nombre;
                }
                context.read<AccessControlBloc>().add(
                  CargarVisitasHoy(telefono: telefono),
                );
              },
            );
          }

          if (state is VisitasHoyLoaded) {
            if (state.visitas.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      size: 72,
                      color: AppColors.headingSky,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'No hay visitas programadas para hoy',
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
                return VisitListItemWidget(
                  visita: state.visitas[index],
                  onTap: () {},
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