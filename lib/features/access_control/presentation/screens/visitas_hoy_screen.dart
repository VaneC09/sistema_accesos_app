// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : visitas_hoy_screen.dart
// Módulo    : features/access_control/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-29
// Versión   : 1.2.0
// Descripción: Pantalla de visitas del día para vigilante — RF-025
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/paginacion_local.dart';
import '../../../../core/widgets/safe_scaffold_body_widget.dart';
import '../../../../core/widgets/empty_list_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/list_stats_header_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/paginated_list_column_widget.dart';
import '../../bloc/access_control_bloc.dart';
import '../../data/access_repository.dart';
import '../widgets/visit_list_item_widget.dart';

class VisitasHoyScreen extends StatelessWidget {
  const VisitasHoyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AccessControlBloc(
        repository: AccessRepository(),
      )..add(const CargarVisitasHoy(telefono: '')),
      child: const _VisitasHoyView(),
    );
  }
}

class _VisitasHoyView extends StatefulWidget {
  const _VisitasHoyView();

  @override
  State<_VisitasHoyView> createState() => _VisitasHoyViewState();
}

class _VisitasHoyViewState extends State<_VisitasHoyView> {
  final _storage = const FlutterSecureStorage();
  String _telefono = '';
  int _paginaActual = 1;

  @override
  void initState() {
    super.initState();
    _cargarTelefonoYVisitas();
  }

  Future<void> _cargarTelefonoYVisitas() async {
    final tel =
        await _storage.read(key: AppConfig.claveTelefonoVigilante) ?? '';
    if (mounted) {
      setState(() => _telefono = tel);
      context.read<AccessControlBloc>().add(CargarVisitasHoy(telefono: tel));
    }
  }

  void _recargar({int? pagina}) {
    if (pagina != null) setState(() => _paginaActual = pagina);
    context.read<AccessControlBloc>().add(CargarVisitasHoy(telefono: _telefono));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseSurface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryCoral,
        elevation: 0,
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
            tooltip: 'Actualizar',
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.baseSurface,
            ),
            onPressed: () {
              setState(() => _paginaActual = 1);
              _recargar();
            },
          ),
        ],
      ),
      body: SafeScaffoldBody(
        child: BlocBuilder<AccessControlBloc, AccessControlState>(
        builder: (context, state) {
          if (state is AccessControlLoading) {
            return const LoadingWidget(
              mensaje: 'Cargando visitas del día...',
            );
          }

          if (state is AccessControlError) {
            return ErrorMessageWidget(
              mensaje: state.mensaje,
              onReintentar: _recargar,
            );
          }

          if (state is VisitasHoyLoaded) {
            final paginado = PaginacionLocal.paginar(
              state.visitas,
              pagina: _paginaActual,
            );

            if (state.visitas.isEmpty) {
              return EmptyListStateWidget(
                icono: Icons.event_available_rounded,
                titulo: 'No hay visitas programadas para hoy',
                subtitulo:
                    'Cuando se autoricen accesos aparecerán aquí con su horario.',
                accionTexto: 'Actualizar',
                onAccion: _recargar,
              );
            }

            return Column(
              children: [
                ListStatsHeaderWidget(
                  titulo: 'Visitas programadas hoy',
                  paginacion: paginado.paginacion,
                  icono: Icons.calendar_today_rounded,
                  colorAcento: AppColors.headingDark,
                ),
                Expanded(
                  child: PaginatedListColumnWidget(
                    paginacion: paginado.paginacion,
                    onPaginaSeleccionada: (pagina) {
                      setState(() => _paginaActual = pagina);
                    },
                    child: RefreshIndicator(
                      color: AppColors.primaryCoral,
                      onRefresh: () async => _recargar(),
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: paginado.items.length,
                        itemBuilder: (context, index) {
                          return VisitListItemWidget(
                            visita: paginado.items[index],
                            onTap: () {},
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
    );
  }
}
