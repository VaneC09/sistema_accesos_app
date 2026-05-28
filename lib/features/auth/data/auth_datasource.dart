// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : auth_datasource.dart
// Módulo    : features/auth/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Fuente de datos de autenticación mock — RF-009, RF-010
// =============================================================================

import '../../../core/connection/api_client.dart';
import '../../../core/errors/app_logger.dart';
import 'auth_model.dart';

class AuthDatasource {
  final ApiClient _apiClient;
  static const String _modulo = 'AUTH_DATASOURCE';

  AuthDatasource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instancia;

  // Login empleado (solicitante / autorizador) — SIN CAMBIOS
  Future<AuthModel> login(String usuario, String contrasena) async {
    AppLogger.info(_modulo, 'Intentando login: $usuario');

    final respuesta = await _apiClient.post(
      '/login',
      datos: {'usuario': usuario, 'password': contrasena},
    );

    final body    = respuesta.data as Map<String, dynamic>;
    final payload = body['data'] as Map<String, dynamic>;

    AppLogger.info(_modulo, 'Login exitoso — rol: ${payload['rol']}');
    return AuthModel.fromJson(payload);
  }

  // Login vigilante — el servidor solo valida formato, no busca en BD
  Future<AuthModel> loginVigilante(String telefono, String area) async {
    AppLogger.info(_modulo, 'Login vigilante — area: $area');

    final respuesta = await _apiClient.post(
      '/vigilante/login',
      datos: {'telefono': telefono, 'area': area},
    );

    final body    = respuesta.data as Map<String, dynamic>;
    final payload = body['data'] as Map<String, dynamic>;

    AppLogger.info(_modulo, 'Login vigilante exitoso');
    return AuthModel.fromJson(payload);
  }

  Future<void> logout(String token) async {
    AppLogger.info(_modulo, 'Cerrando sesión en backend');
    // El vigilante no tiene sesión en backend — solo el empleado
    await _apiClient.post('/logout');
  }
}