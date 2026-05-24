// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : mis_solicitudes_screen.dart
// Módulo    : features/visit_request/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Pantalla de listado de solicitudes — RF-017
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../bloc/visit_request_bloc.dart';
import '../../data/visit_request_repository.dart';
import '../widgets/solicitud_card_widget.dart';

class MisSolicitudesScreen extends StatelessWidget {
  const MisSolicitudesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VisitRequestBloc(
        repository: VisitRequestRepository(),
      )..add(const CargarMisSolicitudes()),
      child: const _MisSolicitudesView(),
    );
  }
}

class _MisSolicitudesView extends StatefulWidget {
  const _MisSolicitudesView();

  @override
  State<_MisSolicitudesView> createState() => _MisSolicitudesViewState();
}

class _MisSolicitudesViewState extends State<_MisSolicitudesView> {
  String? _filtroEstado;

  final List<String> _estados = [
    'Todos',
    'Pendiente',
    'Autorizada',
    'Rechazada',
    'Cancelada',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseSurface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryCoral,
        title: const Text(
          AppStrings.menuMisSolicitudes,
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
      body: Column(
        children: [
          // Filtros por estado
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              itemCount: _estados.length,
              itemBuilder: (context, index) {
                final estado = _estados[index];
                final seleccionado = estado == 'Todos'
                    ? _filtroEstado == null
                    : _filtroEstado == estado;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _filtroEstado = estado == 'Todos' ? null : estado;
                    });
                    context.read<VisitRequestBloc>().add(
                      CargarMisSolicitudes(estado: _filtroEstado),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: seleccionado
                          ? AppColors.primaryCoral
                          : AppColors.surface,
                      borderRadius:
                      BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: Text(
                      estado,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: seleccionado
                            ? AppColors.baseSurface
                            : AppColors.headingDark,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Lista de solicitudes
          Expanded(
            child: BlocBuilder<VisitRequestBloc, VisitRequestState>(
              builder: (context, state) {
                if (state is VisitRequestLoading) {
                  return const LoadingWidget(
                    mensaje: 'Cargando solicitudes...',
                  );
                }

                if (state is VisitRequestError) {
                  return ErrorMessageWidget(
                    mensaje: state.mensaje,
                    onReintentar: () {
                      context.read<VisitRequestBloc>().add(
                        CargarMisSolicitudes(estado: _filtroEstado),
                      );
                    },
                  );
                }

                if (state is MisSolicitudesLoaded) {
                  if (state.solicitudes.isEmpty) {
                    return const Center(
                      child: Text(
                        'No tienes solicitudes registradas',
                        style: TextStyle(
                          color: AppColors.neutralGrey,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: state.solicitudes.length,
                    itemBuilder: (context, index) {
                      return SolicitudCardWidget(
                        solicitud: state.solicitudes[index],
                        onTap: () {},
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}