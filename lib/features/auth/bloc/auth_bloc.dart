// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : auth_bloc.dart
// Módulo    : features/auth/bloc
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Gestor de estado de autenticación — RF-009, RF-010, RF-011, RF-012
// =============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../business/auth_validator.dart';
import '../data/auth_repository.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/errors/app_logger.dart';

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

// ── Estados ──────────────────────────────────────────────────────────────────
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String rol;
  final String nombre;
  final String correoPersonal;
  final String correoPuesto;
  final int idEmpleado;
  final int idDepartamento;

  const AuthAuthenticated({
    required this.rol,
    required this.nombre,
    required this.correoPersonal,
    required this.correoPuesto,
    required this.idEmpleado,
    required this.idDepartamento,
  });

  @override
  List<Object> get props => [
    rol,
    nombre,
    correoPersonal,
    correoPuesto,
    idEmpleado,
    idDepartamento,
  ];
}

class AuthError extends AuthState {
  final String mensaje;

  const AuthError({required this.mensaje});

  @override
  List<Object> get props => [mensaje];
}

class AuthUnauthenticated extends AuthState {}

class AuthBlocked extends AuthState {}

// ── Bloc ─────────────────────────────────────────────────────────────────────
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const String _modulo = 'AUTH_BLOC';
  final AuthRepository _repository;
  int _intentosFallidos = 0;
  static const int _maxIntentos = 5;

  AuthBloc({AuthRepository? repository})
      : _repository = repository ?? AuthRepository(),
        super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginVigilante>(_onLoginVigilante);
    on<LogoutRequested>(_onLogoutRequested);
    on<SessionExpired>(_onSessionExpired);
    on<VerificarSesion>(_onVerificarSesion);
  }

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
        nombre: modelo.nombre,
        correoPersonal: modelo.correoPersonal,
        correoPuesto: modelo.correoPuesto,
        idEmpleado: modelo.idEmpleado,
        idDepartamento: modelo.idDepartamento,
      ));
    } on ValidationException catch (e) {
      emit(AuthError(mensaje: e.mensaje));
    } on UnauthorizedException {
      _intentosFallidos++;
      AppLogger.warning(
        _modulo,
        'Intento fallido $_intentosFallidos/$_maxIntentos',
      );
      if (_intentosFallidos >= _maxIntentos) {
        AppLogger.critical(_modulo, 'Cuenta bloqueada: ${event.usuario}');
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

  Future<void> _onLoginVigilante(
      LoginVigilante event,
      Emitter<AuthState> emit,
      ) async {
    try {
      AuthValidator.validarLoginVigilante(event.telefono, event.area);

      emit(AuthLoading());

      final modelo = await _repository.loginVigilante(
        event.telefono,
        event.area,
      );

      AppLogger.info(_modulo, 'Login vigilante exitoso — ${event.area}');

      emit(AuthAuthenticated(
        rol: modelo.rol,
        nombre: modelo.nombre,
        correoPersonal: modelo.correoPersonal,
        correoPuesto: modelo.correoPuesto,
        idEmpleado: modelo.idEmpleado,
        idDepartamento: modelo.idDepartamento,
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

  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    try {
      await _repository.logout();
      _intentosFallidos = 0;
      AppLogger.info(_modulo, 'Sesión cerrada correctamente');
      emit(AuthUnauthenticated());
    } catch (e) {
      AppLogger.error(_modulo, 'Error al cerrar sesión: $e');
      emit(AuthUnauthenticated());
    }
  }

  void _onSessionExpired(
      SessionExpired event,
      Emitter<AuthState> emit,
      ) {
    AppLogger.warning(_modulo, 'Sesión expirada por inactividad');
    emit(AuthUnauthenticated());
  }

  Future<void> _onVerificarSesion(
      VerificarSesion event,
      Emitter<AuthState> emit,
      ) async {
    try {
      final modelo = await _repository.obtenerSesionActiva();
      if (modelo != null) {
        emit(AuthAuthenticated(
          rol: modelo.rol,
          nombre: modelo.nombre,
          correoPersonal: modelo.correoPersonal,
          correoPuesto: modelo.correoPuesto,
          idEmpleado: modelo.idEmpleado,
          idDepartamento: modelo.idDepartamento,
        ));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }
}