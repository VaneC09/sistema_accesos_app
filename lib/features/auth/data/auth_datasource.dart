// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : auth_datasource.dart
// Módulo    : features/auth/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Fuente de datos de autenticación — RF-009, RF-010
// =============================================================================

import '../../../core/connection/api_client.dart';
import '../../../core/errors/app_logger.dart';
import 'auth_model.dart';

class AuthDatasource {
  final ApiClient _apiClient;
  static const String _modulo = 'AUTH_DATASOURCE';

  AuthDatasource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instancia;

  // Login institucional contra SAM vía Laravel
  Future<AuthModel> login(String usuario, String contrasena) async {
    AppLogger.info(_modulo, 'Intentando login: $usuario');

    final respuesta = await _apiClient.post(
      '/auth/login',
      datos: {
        'usuario': usuario,
        'password': contrasena,
      },
    );

    AppLogger.info(_modulo, 'Login exitoso: $usuario');
    return AuthModel.fromJson(respuesta.data);
  }

  // Login de vigilante
  Future<AuthModel> loginVigilante(String telefono, String area) async {
    AppLogger.info(_modulo, 'Login vigilante — área: $area');

    final respuesta = await _apiClient.post(
      '/vigilante/login',
      datos: {
        'telefono': telefono,
        'area': area,
      },
    );

    AppLogger.info(_modulo, 'Login vigilante exitoso');
    return AuthModel.fromJson(respuesta.data);
  }

  // Cerrar sesión — invalida token en backend
  Future<void> logout(String token) async {
    AppLogger.info(_modulo, 'Cerrando sesión en backend');

    await _apiClient.post('/auth/logout');

    AppLogger.info(_modulo, 'Sesión cerrada en backend');
  }
}