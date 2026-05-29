// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : paginated_list_column_widget.dart
// Módulo    : core/widgets
// Descripción: Columna lista + barra de paginación reutilizable.
// =============================================================================

import 'package:flutter/material.dart';
import '../models/paginacion_model.dart';
import 'pagination_bar_widget.dart';

class PaginatedListColumnWidget extends StatelessWidget {
  final PaginacionModel paginacion;
  final ValueChanged<int> onPaginaSeleccionada;
  final Widget child;
  final bool cargando;

  const PaginatedListColumnWidget({
    super.key,
    required this.paginacion,
    required this.onPaginaSeleccionada,
    required this.child,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: child),
        PaginationBarWidget(
          paginacion: paginacion,
          onPaginaSeleccionada: onPaginaSeleccionada,
          cargando: cargando,
        ),
      ],
    );
  }
}
