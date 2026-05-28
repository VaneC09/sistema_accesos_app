// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : visitas_hoy_screen.dart
// Módulo    : features/access_control/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-27
// Versión   : 1.0.1
// Descripción: Pantalla de visitas del día para vigilante — RF-025 (Fix Storage)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
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
      )..add(const CargarVisitasHoy(telefono: '')), // Se sobreescribe con el teléfono real en el initState del View
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

  @override
  void initState() {
    super.initState();
    _cargarTelefonoYVisitas();
  }

  /// Recupera el teléfono almacenado localmente e inicia la carga de datos en el BLOC
  Future<void> _cargarTelefonoYVisitas() async {
    final tel = await _storage.read(key: AppConfig.claveTelefonoVigilante) ?? '';
    if (mounted) {
      setState(() {
        _telefono = tel;
      });
      context.read<AccessControlBloc>().add(CargarVisitasHoy(telefono: tel));
    }
  }

  /// Invoca la recarga de información utilizando el teléfono en memoria
  void _recargar() {
    context.read<AccessControlBloc>().add(CargarVisitasHoy(telefono: _telefono));
  }

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
            onPressed: _recargar,
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
              onReintentar: _recargar,
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