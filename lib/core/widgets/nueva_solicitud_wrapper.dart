// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : nueva_solicitud_wrapper.dart
// Módulo    : core/widgets
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Wrapper para inyectar el bloc de solicitud de visita
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/visit_request/bloc/visit_request_bloc.dart';
import '../../features/visit_request/data/visit_request_repository.dart';
import '../../features/visit_request/presentation/screens/visit_request_screen.dart';

class NuevaSolicitudWrapper extends StatelessWidget {
  const NuevaSolicitudWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VisitRequestBloc(
        repository: VisitRequestRepository(),
      )..add(CargarCatalogos()),
      child: VisitRequestScreen(),
    );
  }
}