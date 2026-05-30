// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : auth_bloc.dart
// Módulo    : features/auth/bloc
// Autor     : Omega Company
// Fecha     : 2026-05-29
// Versión   : 1.3.0
// Descripción: Gestión de autenticación para todos los roles.
//              Cambios:
//                - Conserva flujo de vigilante con telefono, area y timer.
//                - Agrega soporte para roles múltiples.
// =============================================================================

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../business/auth_validator.dart';
import '../business/auth_session_service.dart';
import '../business/sesion_estado.dart';
import '../data/auth_repository.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/errors/app_logger.dart';
import '../../../core/config/app_config.dart';

// ── Eventos ──────────────────────────────────────────────────────────────────
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String usuario;
  final String contrasena;

  const LoginSubmitted({
    required this.usuario,
    required this.contrasena,
  });

  @override
  List<Object> get props => [usuario, contrasena];
}

class LoginVigilante extends AuthEvent {
  final String telefono;
  final String area;

  const LoginVigilante({
    required this.telefono,
    required this.area,
  });

  @override
  List<Object> get props => [telefono, area];
}

class LogoutRequested extends AuthEvent {}

class SessionExpired extends AuthEvent {}

class VerificarSesion extends AuthEvent {}

class _VigilanteTick extends AuthEvent {}

// ── Estados ──────────────────────────────────────────────────────────────────
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthBlocked extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String rol;
  final List<String> roles;
  final String nombre;
  final String correoPersonal;
  final String correoPuesto;
  final int idEmpleado;
  final int idDepartamento;
  final int idEscuela;
  final String nombreEscuela;

  const AuthAuthenticated({
    required this.rol,
    required this.roles,
    required this.nombre,
    required this.correoPersonal,
    required this.correoPuesto,
    required this.idEmpleado,
    required this.idDepartamento,
    this.idEscuela = 1,
    this.nombreEscuela = 'Instituto Tecnológico de Toluca',
  });

  @override
  List<Object> get props => [
        rol,
        roles,
        nombre,
        correoPersonal,
        correoPuesto,
        idEmpleado,
        idDepartamento,
        idEscuela,
        nombreEscuela,
      ];
}

class AuthError extends AuthState {
  final String mensaje;

  const AuthError({
    required this.mensaje,
  });

  @override
  List<Object> get props => [mensaje];
}

class AuthUnauthenticated extends AuthState {
  final SesionEstado? motivo;

  const AuthUnauthenticated({
    this.motivo,
  });

  @override
  List<Object> get props => [motivo?.name ?? ''];
}

// ── Bloc ─────────────────────────────────────────────────────────────────────
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const String _modulo = 'AUTH_BLOC';

  final AuthRepository _repository;
  final AuthSessionService _sessionService;

  int _intentosFallidos = 0;
  static const int _maxIntentos = 5;
  Timer? _timerVigilante;

  AuthBloc({
    AuthRepository? repository,
    AuthSessionService? sessionService,
  })  : _repository = repository ?? AuthRepository(),
        _sessionService = sessionService ?? AuthSessionService(),
        super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginVigilante>(_onLoginVigilante);
    on<LogoutRequested>(_onLogoutRequested);
    on<SessionExpired>(_onSessionExpired);
    on<VerificarSesion>(_onVerificarSesion);
    on<_VigilanteTick>(_onVigilanteTick);
  }

  // ── Timer vigilante ────────────────────────────────────────────────────────
  void _arrancarTimer() {
    _timerVigilante?.cancel();
    _timerVigilante = Timer.periodic(
      const Duration(seconds: 60),
          (_) => add(_VigilanteTick()),
    );
  }

  void _detenerTimer() {
    _timerVigilante?.cancel();
    _timerVigilante = null;
  }

  Future<void> registrarActividadVigilante() async {
    await _sessionService.registrarActividad();
  }

  // ── Login empleado / solicitante / autorizador ─────────────────────────────
  Future<void> _onLoginSubmitted(
      LoginSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    try {
      AuthValidator.validarLogin(event.usuario, event.contrasena);

      if (_intentosFallidos >= _maxIntentos) {
        emit(AuthBlocked());
        return;
      }

      emit(AuthLoading());

      final modelo = await _repository.login(
        event.usuario,
        event.contrasena,
      );

      _intentosFallidos = 0;

      AppLogger.info(_modulo, 'Login exitoso: ${event.usuario}');

      emit(AuthAuthenticated(
        rol: modelo.rol,
        roles: modelo.roles,
        nombre: modelo.nombre,
        correoPersonal: modelo.correoPersonal,
        correoPuesto: modelo.correoPuesto,
        idEmpleado: modelo.idEmpleado,
        idDepartamento: modelo.idDepartamento,
        idEscuela: modelo.idEscuela,
        nombreEscuela: modelo.nombreEscuela,
      ));
    } on ValidationException catch (e) {
      emit(AuthError(mensaje: e.mensaje));
    } on UnauthorizedException {
      _intentosFallidos++;

      if (_intentosFallidos >= _maxIntentos) {
        emit(AuthBlocked());
      } else {
        emit(const AuthError(
          mensaje: 'Credenciales inválidas. Intente nuevamente',
        ));
      }
    } on AppException catch (e) {
      emit(AuthError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error inesperado: $e');
      emit(const AuthError(
        mensaje: 'Error inesperado. Contacte al administrador',
      ));
    }
  }

  // ── Login vigilante ────────────────────────────────────────────────────────
  Future<void> _onLoginVigilante(
      LoginVigilante event,
      Emitter<AuthState> emit,
      ) async {
    try {
      AuthValidator.validarLoginVigilante(event.telefono, event.area);

      emit(AuthLoading());

      final modeloRaw = await _repository.loginVigilante(
        event.telefono,
        event.area,
      );

      final modelo = modeloRaw.copyWithVigilante(
        telefono: event.telefono,
        area: event.area,
      );

      const storage = FlutterSecureStorage();

      await storage.write(
        key: AppConfig.claveTelefonoVigilante,
        value: event.telefono,
      );

      await storage.write(
        key: AppConfig.claveAreaVigilante,
        value: event.area,
      );

      await _sessionService.iniciarJornada();

      _arrancarTimer();

      AppLogger.info(
        _modulo,
        'Vigilante identificado — ${event.area} | tel: ${event.telefono}',
      );

      emit(AuthAuthenticated(
        rol: modelo.rol,
        roles: modelo.roles,
        nombre: modelo.nombre,
        correoPersonal: modelo.correoPersonal,
        correoPuesto: modelo.correoPuesto,
        idEmpleado: modelo.idEmpleado,
        idDepartamento: modelo.idDepartamento,
        idEscuela: modelo.idEscuela,
        nombreEscuela: modelo.nombreEscuela,
      ));
    } on ValidationException catch (e) {
      emit(AuthError(mensaje: e.mensaje));
    } on AppException catch (e) {
      emit(AuthError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error inesperado vigilante: $e');
      emit(const AuthError(
        mensaje: 'No fue posible registrar el acceso. Intente nuevamente',
      ));
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    try {
      await _repository.logout();
    } catch (_) {}

    _intentosFallidos = 0;

    _detenerTimer();

    await _sessionService.limpiarSesion();

    const storage = FlutterSecureStorage();

    await storage.delete(key: AppConfig.claveTelefonoVigilante);
    await storage.delete(key: AppConfig.claveAreaVigilante);

    emit(const AuthUnauthenticated());
  }

  void _onSessionExpired(
      SessionExpired event,
      Emitter<AuthState> emit,
      ) {
    _detenerTimer();
    _sessionService.limpiarSesion();
    emit(const AuthUnauthenticated());
  }

  // ── Verificar sesión guardada ──────────────────────────────────────────────
  Future<void> _onVerificarSesion(
      VerificarSesion event,
      Emitter<AuthState> emit,
      ) async {
    try {
      final modelo = await _repository.obtenerSesionActiva();

      if (modelo == null) {
        emit(const AuthUnauthenticated());
        return;
      }

      if (modelo.rol == 'vigilante') {
        final estado = await _sessionService.esSesionValida();

        if (!estado.esValida) {
          await _sessionService.limpiarSesion();
          emit(AuthUnauthenticated(motivo: estado));
          return;
        }

        _arrancarTimer();
      }

      emit(AuthAuthenticated(
        rol: modelo.rol,
        roles: modelo.roles,
        nombre: modelo.nombre,
        correoPersonal: modelo.correoPersonal,
        correoPuesto: modelo.correoPuesto,
        idEmpleado: modelo.idEmpleado,
        idDepartamento: modelo.idDepartamento,
        idEscuela: modelo.idEscuela,
        nombreEscuela: modelo.nombreEscuela,
      ));
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  // ── Timer vigilante ────────────────────────────────────────────────────────
  Future<void> _onVigilanteTick(
      _VigilanteTick event,
      Emitter<AuthState> emit,
      ) async {
    if (state is! AuthAuthenticated) return;

    if ((state as AuthAuthenticated).rol != 'vigilante') return;

    final estado = await _sessionService.esSesionValida();

    if (!estado.esValida) {
      AppLogger.warning(
        _modulo,
        'Sesión vigilante expirada: ${estado.name}',
      );

      _detenerTimer();

      await _sessionService.limpiarSesion();

      emit(AuthUnauthenticated(motivo: estado));
    }
  }

  @override
  Future<void> close() {
    _detenerTimer();
    return super.close();
  }
}