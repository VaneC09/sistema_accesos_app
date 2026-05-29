// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : authorization_datasource.dart
// Módulo    : features/visit_authorization/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Fuente de datos de autorización — RF-019, RF-020
// =============================================================================

import '../../../core/connection/api_client.dart';
import '../../../core/connection/api_response_helper.dart';
import '../../../core/constants/filtro_estado_solicitud.dart';
import '../../../core/errors/app_logger.dart';
import '../../../core/models/paginated_result.dart';
import 'authorization_model.dart';

class AuthorizationDatasource {
  final ApiClient _apiClient;
  static const String _modulo = 'AUTHORIZATION_DATASOURCE';

  AuthorizationDatasource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instancia;

  Future<PaginatedResult<AuthorizationModel>> obtenerPendientes({
    String? estado,
    int pagina = 1,
  }) async {
    AppLogger.info(_modulo, 'Obteniendo solicitudes del autorizador');

    final parametros = <String, dynamic>{
      'page': pagina,
      'filtro': FiltroEstadoSolicitud.parametroAutorizador(estado),
    };

    final respuesta = await _apiClient.get(
      '/autorizador/solicitudes',
      parametros: parametros,
    );

    final mapas = ApiResponseHelper.extraerMapas(respuesta.data);
    final items = mapas.map(AuthorizationModel.fromJson).toList();
    final paginacion = ApiResponseHelper.extraerPaginacion(
      respuesta.data,
      cantidadItems: items.length,
    );

    return PaginatedResult(items: items, paginacion: paginacion);
  }

  Future<AuthorizationModel> obtenerDetalle(int idSolicitud) async {
    AppLogger.info(_modulo, 'Obteniendo detalle de solicitud: $idSolicitud');

    final respuesta = await _apiClient.get('/solicitudes/$idSolicitud');

    final data = respuesta.data as Map<String, dynamic>;
    final solicitudJson = data['data'] as Map<String, dynamic>;

    return AuthorizationModel.fromJson(solicitudJson);
  }

  Future<void> autorizar(int idSolicitud) async {
    AppLogger.info(_modulo, 'Autorizando solicitud: $idSolicitud');

    await _apiClient.post('/autorizador/$idSolicitud/autorizar');
  }

  Future<void> rechazar(int idSolicitud, String motivo) async {
    AppLogger.info(_modulo, 'Rechazando solicitud: $idSolicitud');

    await _apiClient.post(
      '/autorizador/$idSolicitud/rechazar',
      datos: {
        'motivo': motivo,
      },
    );
  }
}