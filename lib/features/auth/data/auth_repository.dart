// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : auth_repository.dart
// Módulo    : features/auth/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Repositorio de autenticación — RF-009, RF-010, RF-011, RF-012
// =============================================================================
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/config/app_config.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/errors/app_logger.dart';
import 'auth_datasource.dart';
import 'auth_model.dart';

class AuthRepository {
  final AuthDatasource _datasource;
  final FlutterSecureStorage _storage;
  static const String _modulo = 'AUTH_REPOSITORY';

  AuthRepository({
    AuthDatasource? datasource,
    FlutterSecureStorage? storage,
  })  : _datasource = datasource ?? AuthDatasource(),
        _storage = storage ?? const FlutterSecureStorage();

  Future<AuthModel> login(String usuario, String contrasena) async {
    try {
      final modelo = await _datasource.login(usuario, contrasena);
      await _guardarSesion(modelo);
      return modelo;
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error inesperado en login: $e');
      throw const ServerException(
        mensaje: 'Error inesperado. Contacte al administrador',
      );
    }
  }

  Future<AuthModel> loginVigilante(String telefono, String area) async {
    try {
      final modelo = await _datasource.loginVigilante(telefono, area);
      await _guardarSesion(modelo);
      return modelo;
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error inesperado en login vigilante: $e');
      throw const ServerException(
        mensaje: 'No fue posible registrar el acceso. Intente nuevamente',
      );
    }
  }

  Future<void> logout() async {
    try {
      await _datasource.logout('');
    } catch (e) {
      AppLogger.warning(_modulo, 'Error al cerrar sesión en backend: $e');
    } finally {
      await _limpiarSesion();
    }
  }

  Future<AuthModel?> obtenerSesionActiva() async {
    try {
      final token = await _storage.read(key: AppConfig.claveToken);
      if (token == null) return null;

      final usuarioJson = await _storage.read(key: AppConfig.claveUsuario);
      if (usuarioJson == null) return null;

      return AuthModel.fromString(usuarioJson);
    } catch (e) {
      AppLogger.error(_modulo, 'Error al obtener sesión activa: $e');
      return null;
    }
  }

  Future<void> _guardarSesion(AuthModel modelo) async {
    await _storage.write(
      key: AppConfig.claveToken,
      value: modelo.token,
    );
    await _storage.write(
      key: AppConfig.claveUsuario,
      value: modelo.toString(),
    );
    await _storage.write(
      key: AppConfig.claveRol,
      value: modelo.rol,
    );
    AppLogger.info(_modulo, 'Sesión guardada — rol: ${modelo.rol}');
  }

  Future<void> _limpiarSesion() async {
    await _storage.delete(key: AppConfig.claveToken);
    await _storage.delete(key: AppConfig.claveUsuario);
    await _storage.delete(key: AppConfig.claveRol);
    AppLogger.info(_modulo, 'Sesión eliminada del almacenamiento seguro');
  }
}
