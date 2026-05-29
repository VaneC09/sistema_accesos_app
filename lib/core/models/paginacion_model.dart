// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : paginacion_model.dart
// Módulo    : core/models
// Descripción: Metadatos de paginación Laravel (current_page, last_page, etc.).
// =============================================================================

import 'package:equatable/equatable.dart';

class PaginacionModel extends Equatable {
  final int paginaActual;
  final int totalPaginas;
  final int totalRegistros;
  final int porPagina;

  const PaginacionModel({
    this.paginaActual = 1,
    this.totalPaginas = 1,
    this.totalRegistros = 0,
    this.porPagina = 10,
  });

  static const PaginacionModel vacia = PaginacionModel();

  bool get hayAnterior => paginaActual > 1;
  bool get haySiguiente => paginaActual < totalPaginas;
  bool get muestraControles => totalPaginas > 1;

  /// Hasta 5 índices centrados en la página actual.
  List<int> get indicesVisibles {
    if (totalPaginas <= 1) return const [1];

    const maxVisible = 5;
    var inicio = paginaActual - 2;
    if (inicio < 1) inicio = 1;

    var fin = inicio + maxVisible - 1;
    if (fin > totalPaginas) {
      fin = totalPaginas;
      inicio = (fin - maxVisible + 1).clamp(1, totalPaginas);
    }

    return List.generate(fin - inicio + 1, (i) => inicio + i);
  }

  @override
  List<Object?> get props =>
      [paginaActual, totalPaginas, totalRegistros, porPagina];
}
