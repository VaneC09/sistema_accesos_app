// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : paginacion_local.dart
// Módulo    : core/utils
// Descripción: Paginación en cliente cuando el API devuelve lista completa.
// =============================================================================

import '../config/app_config.dart';
import '../models/paginated_result.dart';
import '../models/paginacion_model.dart';

class PaginacionLocal {
  PaginacionLocal._();

  static PaginatedResult<T> paginar<T>(
    List<T> todos, {
    required int pagina,
    int porPagina = AppConfig.registrosPorPagina,
  }) {
    final total = todos.length;

    if (total == 0) {
      return const PaginatedResult(
        items: [],
        paginacion: PaginacionModel.vacia,
      );
    }

    final totalPaginas = (total / porPagina).ceil();
    final paginaActual = pagina.clamp(1, totalPaginas);
    final inicio = (paginaActual - 1) * porPagina;
    final fin = (inicio + porPagina).clamp(0, total);

    return PaginatedResult(
      items: todos.sublist(inicio, fin),
      paginacion: PaginacionModel(
        paginaActual: paginaActual,
        totalPaginas: totalPaginas,
        totalRegistros: total,
        porPagina: porPagina,
      ),
    );
  }
}
