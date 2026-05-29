// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : autorizaciones_screen.dart
// Módulo    : features/visit_authorization/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-29
// Versión   : 1.1.0
// Descripción: Pantalla de solicitudes del autorizador con filtro por estado — RF-019
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/safe_scaffold_body_widget.dart';
import '../../../../core/widgets/estado_filtro_bar_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_list_state_widget.dart';
import '../../../../core/widgets/list_stats_header_widget.dart';
import '../../../../core/widgets/paginated_list_column_widget.dart';
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
      )..add(const CargarPendientes()),
      child: const _AutorizacionesView(),
    );
  }
}

class _AutorizacionesView extends StatefulWidget {
  const _AutorizacionesView();

  @override
  State<_AutorizacionesView> createState() => _AutorizacionesViewState();
}

class _AutorizacionesViewState extends State<_AutorizacionesView> {
  String? _filtroEstado;
  int _paginaActual = 1;

  void _recargar({int? pagina}) {
    final paginaDestino = pagina ?? _paginaActual;
    setState(() => _paginaActual = paginaDestino);
    context.read<VisitAuthorizationBloc>().add(
          CargarPendientes(
            estado: _filtroEstado,
            pagina: paginaDestino,
          ),
        );
  }

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
            onPressed: _recargar,
          ),
        ],
      ),
      body: SafeScaffoldBody(
        child: Column(
          children: [
          EstadoFiltroBarWidget(
            filtroSeleccionado: _filtroEstado,
            onFiltroChanged: (estado) {
              setState(() {
                _filtroEstado = estado;
                _paginaActual = 1;
              });
              _recargar(pagina: 1);
            },
          ),
          Expanded(
            child: BlocBuilder<VisitAuthorizationBloc, VisitAuthorizationState>(
              builder: (context, state) {
                if (state is VisitAuthorizationLoading) {
                  return const LoadingWidget(
                    mensaje: 'Cargando solicitudes...',
                  );
                }

                if (state is VisitAuthorizationError) {
                  return ErrorMessageWidget(
                    mensaje: state.mensaje,
                    onReintentar: _recargar,
                  );
                }

                if (state is PendientesLoaded) {
                  if (state.pendientes.isEmpty) {
                    return EmptyListStateWidget(
                      icono: _filtroEstado == null ||
                              _filtroEstado == 'Pendiente'
                          ? Icons.check_circle_outline_rounded
                          : Icons.inbox_outlined,
                      colorIcono: _filtroEstado == null ||
                              _filtroEstado == 'Pendiente'
                          ? AppColors.successGreen
                          : null,
                      titulo: _filtroEstado == null
                          ? 'No hay solicitudes registradas'
                          : _filtroEstado == 'Pendiente'
                              ? 'No hay solicitudes pendientes'
                              : 'No hay solicitudes $_filtroEstado',
                      accionTexto: 'Actualizar',
                      onAccion: () => _recargar(pagina: 1),
                    );
                  }

                  return Column(
                    children: [
                      ListStatsHeaderWidget(
                        titulo: 'Solicitudes por autorizar',
                        paginacion: state.paginacion,
                        icono: Icons.approval_rounded,
                      ),
                      Expanded(
                        child: PaginatedListColumnWidget(
                          paginacion: state.paginacion,
                          onPaginaSeleccionada: (pagina) =>
                              _recargar(pagina: pagina),
                          child: RefreshIndicator(
                            color: AppColors.primaryCoral,
                            onRefresh: () async => _recargar(),
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              itemCount: state.pendientes.length,
                              itemBuilder: (context, index) {
                                final solicitud = state.pendientes[index];

                                return AuthorizationCardWidget(
                                  solicitud: solicitud,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider(
                                          create: (_) =>
                                              VisitAuthorizationBloc(
                                            repository:
                                                AuthorizationRepository(),
                                          ),
                                          child: AuthorizationDetailScreen(
                                            solicitud: solicitud,
                                          ),
                                        ),
                                      ),
                                    ).then((_) {
                                      if (mounted) _recargar();
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
        ),
      ),
    );
  }
}
