// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : api_response_helper.dart
// Módulo    : core/connection
// Descripción: Extrae listas de respuestas API (array directo o paginación Laravel).
// =============================================================================

import '../errors/app_logger.dart';
import '../models/paginacion_model.dart';

class ApiResponseHelper {
  ApiResponseHelper._();

  static const String _modulo = 'API_RESPONSE_HELPER';

  /// Soporta:
  /// - `{ "data": [...] }`
  /// - `{ "data": { "data": [...], ...paginador } }` (Laravel)
  /// - `{ "data": { "notificaciones": [...] } }`
  /// - Objetos únicos envueltos como `{ "data": { "data": { ...item } } }`
  static List<dynamic> extraerLista(dynamic body, {String? etiqueta}) {
    if (body == null) return [];
    if (body is List) return body;

    if (body is! Map) {
      _logEstructura(etiqueta, body);
      return [];
    }

    final mapa = Map<String, dynamic>.from(body);

    // Patrón usado en authorization_datasource y visit_request_datasource
    final capa1 = mapa['data'];
    if (capa1 is List) return capa1;

    if (capa1 is Map) {
      final paginador = Map<String, dynamic>.from(capa1);

      final capa2 = paginador['data'];
      if (capa2 is List) return capa2;
      if (capa2 is Map && _esElementoMapeable(capa2)) {
        return [Map<String, dynamic>.from(capa2)];
      }

      for (final clave in ['notificaciones', 'items', 'results', 'records']) {
        final valor = paginador[clave];
        if (valor is List) return valor;
        if (valor is Map) {
          final listaAnidada = extraerLista({'data': valor}, etiqueta: etiqueta);
          if (listaAnidada.isNotEmpty) return listaAnidada;
        }
      }
    }

    final profunda = _buscarListaEnArbol(mapa, 0);
    if (profunda != null && profunda.isNotEmpty) return profunda;

    _logEstructura(etiqueta, mapa);
    return [];
  }

  static List<Map<String, dynamic>> extraerMapas(
    dynamic body, {
    String? etiqueta,
  }) {
    return extraerLista(body, etiqueta: etiqueta)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// Extrae metadatos Laravel: `{ data: { current_page, last_page, total, ... } }`.
  static PaginacionModel extraerPaginacion(
    dynamic body, {
    int cantidadItems = 0,
  }) {
    final paginador = _localizarPaginador(body);
    if (paginador != null) {
      return PaginacionModel(
        paginaActual: _toInt(paginador['current_page'], 1),
        totalPaginas: _toInt(paginador['last_page'], 1),
        totalRegistros: _toInt(paginador['total'], cantidadItems),
        porPagina: _toInt(
          paginador['per_page'],
          cantidadItems > 0 ? cantidadItems : 10,
        ),
      );
    }

    return PaginacionModel(
      paginaActual: 1,
      totalPaginas: 1,
      totalRegistros: cantidadItems,
      porPagina: cantidadItems > 0 ? cantidadItems : 10,
    );
  }

  static Map<String, dynamic>? _localizarPaginador(dynamic body) {
    if (body is! Map) return null;

    final capa1 = body['data'];
    if (capa1 is Map) {
      final mapa = Map<String, dynamic>.from(capa1);
      if (mapa.containsKey('current_page') || mapa.containsKey('last_page')) {
        return mapa;
      }
    }

    return null;
  }

  static int _toInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  static List<dynamic>? _buscarListaEnArbol(dynamic node, int profundidad) {
    if (node == null || profundidad > 8) return null;

    if (node is List) {
      if (node.isEmpty) return node;
      if (node.first is Map || node.first == null) return node;
      return null;
    }

    if (node is Map) {
      for (final entry in node.entries) {
        final valor = entry.value;

        if (valor is List) {
          if (valor.isEmpty || valor.first is Map) return valor;
        }

        if (valor is Map) {
          final anidada = _buscarListaEnArbol(valor, profundidad + 1);
          if (anidada != null && anidada.isNotEmpty) return anidada;
        }
      }
    }

    return null;
  }

  static bool _esElementoMapeable(Map map) {
    return map.containsKey('tipo') ||
        map.containsKey('id_notificaciones') ||
        map.containsKey('id_notificacion') ||
        map.containsKey('id') ||
        map.containsKey('folio');
  }

  static void _logEstructura(String? etiqueta, dynamic body) {
    if (etiqueta == null) return;

    if (body is Map) {
      final capa1 = body['data'];
      AppLogger.warning(
        _modulo,
        '$etiqueta — sin lista. keys=${body.keys.toList()}, '
        'data.type=${capa1.runtimeType}'
        '${capa1 is Map ? ", data.keys=${capa1.keys.toList()}" : ""}',
      );
    } else {
      AppLogger.warning(
        _modulo,
        '$etiqueta — body type=${body.runtimeType}',
      );
    }
  }
}
