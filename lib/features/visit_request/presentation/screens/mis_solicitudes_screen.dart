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
import '../../../../core/widgets/safe_scaffold_body_widget.dart';
import '../../../../core/widgets/estado_filtro_bar_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_list_state_widget.dart';
import '../../../../core/widgets/list_stats_header_widget.dart';
import '../../../../core/widgets/paginated_list_column_widget.dart';
import '../../bloc/visit_request_bloc.dart';
import '../../data/visit_request_repository.dart';
import '../widgets/solicitud_card_widget.dart';
import 'visit_detail_screen.dart';

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
  int _paginaActual = 1;

  void _cargar({int? pagina}) {
    final paginaDestino = pagina ?? _paginaActual;
    setState(() => _paginaActual = paginaDestino);
    context.read<VisitRequestBloc>().add(
          CargarMisSolicitudes(
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
              _cargar(pagina: 1);
            },
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
                    onReintentar: () => _cargar(),
                  );
                }

                if (state is MisSolicitudesLoaded) {
                  if (state.solicitudes.isEmpty) {
                    return EmptyListStateWidget(
                      icono: Icons.inbox_outlined,
                      titulo: _filtroEstado == null
                          ? 'No tienes solicitudes registradas'
                          : 'No tienes solicitudes $_filtroEstado',
                      subtitulo:
                          'Las solicitudes que crees aparecerán aquí con su estado.',
                      accionTexto: 'Actualizar',
                      onAccion: () => _cargar(pagina: 1),
                    );
                  }

                  return Column(
                    children: [
                      ListStatsHeaderWidget(
                        titulo: 'Mis solicitudes de visita',
                        paginacion: state.paginacion,
                        icono: Icons.description_outlined,
                      ),
                      Expanded(
                        child: PaginatedListColumnWidget(
                          paginacion: state.paginacion,
                          onPaginaSeleccionada: (pagina) =>
                              _cargar(pagina: pagina),
                          child: RefreshIndicator(
                            color: AppColors.primaryCoral,
                            onRefresh: () async => _cargar(),
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              itemCount: state.solicitudes.length,
                              itemBuilder: (context, index) {
                                final solicitud = state.solicitudes[index];

                                return SolicitudCardWidget(
                                  solicitud: solicitud,
                                  onTap: () {
                                    if (solicitud.idSolicitud == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'No se pudo abrir el detalle de la solicitud',
                                          ),
                                          backgroundColor: AppColors.actionRed,
                                        ),
                                      );
                                      return;
                                    }

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => VisitDetailScreen(
                                          idSolicitud: solicitud.idSolicitud!,
                                        ),
                                      ),
                                    );
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