// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : app_exceptions.dart
// Módulo    : core/errors
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Excepciones personalizadas centralizadas — MPF-OMEGA-04 §6.3
// =============================================================================

// Excepción base del sistema
class AppException implements Exception {
  final String mensaje;
  final String? codigo;
  final String modulo;

  const AppException({
    required this.mensaje,
    required this.modulo,
    this.codigo,
  });

  @override
  String toString() => '[$modulo] ${codigo ?? ''}: $mensaje';
}

// Error de red o conexión
class NetworkException extends AppException {
  const NetworkException({required super.mensaje})
      : super(modulo: 'RED', codigo: 'NET_001');
}

// Error de autenticación — 401
class UnauthorizedException extends AppException {
  const UnauthorizedException({required super.mensaje})
      : super(modulo: 'AUTH', codigo: 'AUTH_401');
}

// Acceso prohibido — 403
class ForbiddenException extends AppException {
  const ForbiddenException({required super.mensaje})
      : super(modulo: 'AUTH', codigo: 'AUTH_403');
}

// Recurso no encontrado — 404
class NotFoundException extends AppException {
  const NotFoundException({required super.mensaje})
      : super(modulo: 'API', codigo: 'API_404');
}

// Error del servidor — 500+
class ServerException extends AppException {
  const ServerException({required super.mensaje})
      : super(modulo: 'SERVIDOR', codigo: 'SRV_500');
}

// Error de validación de datos
class ValidationException extends AppException {
  const ValidationException({required super.mensaje})
      : super(modulo: 'VALIDACION', codigo: 'VAL_001');
}

// Error de timeout
class TimeoutException extends AppException {
  const TimeoutException({required super.mensaje})
      : super(modulo: 'RED', codigo: 'NET_408');
}

// Error de sesión expirada
class SessionExpiredException extends AppException {
  const SessionExpiredException()
      : super(
    mensaje: 'Sesión cerrada por inactividad',
    modulo: 'AUTH',
    codigo: 'AUTH_SESSION',
  );
}

// Error de credenciales bloqueadas
class AccountBlockedException extends AppException {
  const AccountBlockedException()
      : super(
    mensaje:
    'Acceso bloqueado por múltiples intentos fallidos',
    modulo: 'AUTH',
    codigo: 'AUTH_BLOCKED',
  );
}

// Error de QR inválido
class QrInvalidException extends AppException {
  const QrInvalidException({required super.mensaje})
      : super(modulo: 'QR', codigo: 'QR_001');
}

// Error de lista de exclusión
class ExclusionListException extends AppException {
  const ExclusionListException()
      : super(
    mensaje:
    'Acceso denegado: visitante en lista de exclusión. No permitir ingreso',
    modulo: 'ACCESO',
    codigo: 'ACC_001',
  );
}