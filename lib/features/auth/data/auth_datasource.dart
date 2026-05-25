// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : auth_datasource.dart
// Módulo    : features/auth/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Fuente de datos de autenticación mock — RF-009, RF-010
// =============================================================================

import '../../../core/errors/app_exceptions.dart';
import '../../../core/errors/app_logger.dart';
import 'auth_model.dart';

class AuthDatasource {
  static const String _modulo = 'AUTH_DATASOURCE';

  // Usuarios mock
  static const _usuarios = {
    'empleado@toluca.tecnm.mx': 'empleado',
    'jefe@toluca.tecnm.mx': 'jefe',
    'recursos@toluca.tecnm.mx': 'recursos_materiales',
  };

  Future<AuthModel> login(String usuario, String contrasena) async {
    AppLogger.info(_modulo, 'Login mock: $usuario');
    await Future.delayed(const Duration(seconds: 1));

    if (contrasena != '1234') {
      throw const UnauthorizedException(
        mensaje: 'Credenciales inválidas. Intente nuevamente',
      );
    }

    final rol = _usuarios[usuario.toLowerCase()];
    if (rol == null) {
      throw const UnauthorizedException(
        mensaje: 'Usuario no encontrado. Verifique su correo institucional',
      );
    }

    switch (rol) {
      case 'jefe':
        return AuthModel(
          token: 'mock_token_jefe_123',
          usuario: usuario,
          rol: 'jefe',
          nombre: 'Jefe de Área',
          correoPersonal: usuario,
          correoPuesto: 'sc@toluca.tecnm.mx',
          idEmpleado: 2,
          idDepartamento: 1,
          puesto: 'Jefe de Departamento',
        );
      case 'recursos_materiales':
        return AuthModel(
          token: 'mock_token_recursos_123',
          usuario: usuario,
          rol: 'recursos_materiales',
          nombre: 'Recursos Materiales',
          correoPersonal: usuario,
          correoPuesto: 'rm@toluca.tecnm.mx',
          idEmpleado: 3,
          idDepartamento: 5,
          puesto: 'Encargado',
        );
      default:
        return AuthModel(
          token: 'mock_token_empleado_123',
          usuario: usuario,
          rol: 'empleado',
          nombre: 'Empleado ITT',
          correoPersonal: usuario,
          correoPuesto: '',
          idEmpleado: 1,
          idDepartamento: 2,
          puesto: 'Docente',
        );
    }
  }

  Future<AuthModel> loginVigilante(String telefono, String area) async {
    AppLogger.info(_modulo, 'Login vigilante mock — área: $area');
    await Future.delayed(const Duration(seconds: 1));

    return AuthModel(
      token: 'mock_token_vigilante_123',
      usuario: telefono,
      rol: 'vigilante',
      nombre: 'Vigilante $area',
      correoPersonal: '',
      correoPuesto: '',
      idEmpleado: 0,
      idDepartamento: 0,
      puesto: 'Vigilante',
    );
  }

  Future<void> logout(String token) async {
    AppLogger.info(_modulo, 'Logout mock');
    await Future.delayed(const Duration(milliseconds: 500));
  }
}