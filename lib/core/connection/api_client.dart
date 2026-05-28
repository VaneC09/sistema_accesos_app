// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : api_client.dart
// Módulo    : core/connection
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.1
// Descripción: Cliente HTTP centralizado con Dio — MPF-OMEGA-04 §6.5
// =============================================================================

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../errors/app_exceptions.dart';
import '../errors/app_logger.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient _instancia = ApiClient._();
  static ApiClient get instancia => _instancia;

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _modulo = 'API_CLIENT';

  void inicializar() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: Duration(seconds: AppConfig.timeoutConexionSegundos),
        receiveTimeout: Duration(seconds: AppConfig.timeoutRespuestaSegundos),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    _agregarInterceptores();
    AppLogger.info(_modulo, 'Cliente HTTP inicializado — ${AppConfig.baseUrl}');
  }


  void _agregarInterceptores() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: AppConfig.claveToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          AppLogger.info(_modulo, 'Petición: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.info(
            _modulo,
            'Respuesta: ${response.statusCode} ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) async {
          AppLogger.error(
            _modulo,
            'Error: ${error.response?.statusCode} ${error.requestOptions.path}',
          );

          if (error.response?.statusCode == 401) {
            final esEndpointLogin = error.requestOptions.path.contains('/login');
            if (!esEndpointLogin) {
              AppLogger.warning(_modulo, 'Token expirado — cerrando sesión');
              await _limpiarSesion();
            }
          }

          // ← Solo pasar el DioException original, sin convertir aquí
          return handler.next(error);
        },
      ),
    );
  }


  Future<Response> get(String endpoint, {Map<String, dynamic>? parametros}) async {
    try {
      final respuesta = await _dio.get(endpoint, queryParameters: parametros);
      return respuesta;
    } catch (e) {
      throw _manejarError(e);
    }
  }

  Future<Response> post(String endpoint, {Map<String, dynamic>? datos}) async {
    try {
      final respuesta = await _dio.post(endpoint, data: datos);
      return respuesta;
    } catch (e) {
      throw _manejarError(e);
    }
  }

  Future<Response> put(String endpoint, {Map<String, dynamic>? datos}) async {
    try {
      final respuesta = await _dio.put(endpoint, data: datos);
      return respuesta;
    } catch (e) {
      throw _manejarError(e);
    }
  }

  Future<Response> delete(String endpoint) async {
    try {
      final respuesta = await _dio.delete(endpoint);
      return respuesta;
    } catch (e) {
      throw _manejarError(e);
    }
  }

  AppException _manejarError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          AppLogger.error(_modulo, 'Timeout de conexión');
          return const TimeoutException(
            mensaje: 'Tiempo de espera agotado. Intente nuevamente',
          );
        case DioExceptionType.connectionError:
          AppLogger.error(_modulo, 'Sin conexión a internet');
          return const NetworkException(
            mensaje: 'Sin conexión. Verifique su red e intente nuevamente',
          );
        case DioExceptionType.badResponse:
        // ← Aquí sí tenemos acceso a error.response completo
          return _manejarCodigoHttp(
            error.response?.statusCode,
            error.response,
          );
        default:
          AppLogger.error(_modulo, 'Error desconocido: ${error.message}');
          return const NetworkException(
            mensaje: 'Error de conexión. Intente nuevamente',
          );
      }
    }

    AppLogger.critical(_modulo, 'Error no controlado: $error');
    return const ServerException(
      mensaje: 'Error inesperado. Contacte al administrador',
    );
  }

  AppException _manejarCodigoHttp(int? codigo, [Response? response]) {
    // Extraer mensaje real del backend si existe
    String? mensajeBackend;
    try {
      final body = response?.data;
      if (body is Map) {
        mensajeBackend = body['message'] as String?
            ?? (body['errors'] as Map?)?.values.first?.toString();
      }
    } catch (_) {}

    switch (codigo) {
      case 400:
        return ValidationException(
          mensaje: mensajeBackend ?? 'Datos incorrectos. Verifique la información',
        );
      case 401:
        return UnauthorizedException(
          mensaje: mensajeBackend ?? 'Credenciales inválidas. Intente nuevamente',
        );
      case 403:
        return ForbiddenException(
          mensaje: mensajeBackend ?? 'No tiene permisos para realizar esta acción',
        );
      case 404:
        return NotFoundException(
          mensaje: mensajeBackend ?? 'Recurso no encontrado',
        );
      case 422:
        return ValidationException(
          mensaje: mensajeBackend ?? 'Datos incorrectos. Verifique la información',
        );
      default:
        AppLogger.error(_modulo, 'Error servidor: $codigo');
        return ServerException(
          mensaje: mensajeBackend ?? 'Error del servidor. Intente más tarde',
        );
    }
  }

  Future<void> _limpiarSesion() async {
    await _storage.delete(key: AppConfig.claveToken);
    await _storage.delete(key: AppConfig.claveUsuario);
    await _storage.delete(key: AppConfig.claveRol);
    AppLogger.info(_modulo, 'Sesión eliminada del almacenamiento seguro');
  }

  Future<void> cerrarSesion() async {
    await _limpiarSesion();
  }
}
