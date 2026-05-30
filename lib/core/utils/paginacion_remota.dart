// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : paginacion_remota.dart
// Módulo    : core/utils
// Descripción: Recorre páginas del API para filtrar en cliente con precisión.
// =============================================================================

import '../models/paginated_result.dart';

class PaginacionRemota {
  PaginacionRemota._();

  static Future<List<T>> recopilarPaginas<T>({
    required Future<PaginatedResult<T>> Function(int pagina) obtenerPagina,
    int paginaMaxima = 50,
  }) async {
    final todas = <T>[];
    var pagina = 1;
    var totalPaginas = 1;

    do {
      final resultado = await obtenerPagina(pagina);
      todas.addAll(resultado.items);
      totalPaginas = resultado.paginacion.totalPaginas;
      if (resultado.items.isEmpty) break;
      pagina++;
    } while (pagina <= totalPaginas && pagina <= paginaMaxima);

    return todas;
  }
}
