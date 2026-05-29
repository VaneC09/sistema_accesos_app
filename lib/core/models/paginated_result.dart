// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : paginated_result.dart
// Módulo    : core/models
// Descripción: Resultado paginado genérico (items + metadatos).
// =============================================================================

import 'paginacion_model.dart';

class PaginatedResult<T> {
  final List<T> items;
  final PaginacionModel paginacion;

  const PaginatedResult({
    required this.items,
    required this.paginacion,
  });
}
