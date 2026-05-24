// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : visit_authorization_bloc.dart
// Módulo    : features/visit_authorization/bloc
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Gestor de estado de autorización — RF-019, RF-020
// =============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/authorization_model.dart';
import '../data/authorization_repository.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/errors/app_logger.dart';

// ── Eventos ──────────────────────────────────────────────────────────────────
abstract class VisitAuthorizationEvent extends Equatable {
  const VisitAuthorizationEvent();

  @override
  List<Object?> get props => [];
}

class CargarPendientes extends VisitAuthorizationEvent {}

class CargarDetalle extends VisitAuthorizationEvent {
  final int idSolicitud;

  const CargarDetalle({required this.idSolicitud});

  @override
  List<Object?> get props => [idSolicitud];
}

class AutorizarSolicitud extends VisitAuthorizationEvent {
  final int idSolicitud;

  const AutorizarSolicitud({required this.idSolicitud});

  @override
  List<Object?> get props => [idSolicitud];
}

class RechazarSolicitud extends VisitAuthorizationEvent {
  final int idSolicitud;
  final String motivo;

  const RechazarSolicitud({
    required this.idSolicitud,
    required this.motivo,
  });

  @override
  List<Object?> get props => [idSolicitud, motivo];
}

// ── Estados ──────────────────────────────────────────────────────────────────
abstract class VisitAuthorizationState extends Equatable {
  const VisitAuthorizationState();

  @override
  List<Object?> get props => [];
}

class VisitAuthorizationInitial extends VisitAuthorizationState {}

class VisitAuthorizationLoading extends VisitAuthorizationState {}

class PendientesLoaded extends VisitAuthorizationState {
  final List<AuthorizationModel> pendientes;

  const PendientesLoaded({required this.pendientes});

  @override
  List<Object?> get props => [pendientes];
}

class DetalleLoaded extends VisitAuthorizationState {
  final AuthorizationModel solicitud;

  const DetalleLoaded({required this.solicitud});

  @override
  List<Object?> get props => [solicitud];
}

class AutorizacionSuccess extends VisitAuthorizationState {
  final String mensaje;

  const AutorizacionSuccess({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}

class VisitAuthorizationError extends VisitAuthorizationState {
  final String mensaje;

  const VisitAuthorizationError({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}

// ── Bloc ─────────────────────────────────────────────────────────────────────
class VisitAuthorizationBloc
    extends Bloc<VisitAuthorizationEvent, VisitAuthorizationState> {
  static const String _modulo = 'VISIT_AUTHORIZATION_BLOC';
  final AuthorizationRepository _repository;

  VisitAuthorizationBloc({AuthorizationRepository? repository})
      : _repository = repository ?? AuthorizationRepository(),
        super(VisitAuthorizationInitial()) {
    on<CargarPendientes>(_onCargarPendientes);
    on<CargarDetalle>(_onCargarDetalle);
    on<AutorizarSolicitud>(_onAutorizar);
    on<RechazarSolicitud>(_onRechazar);
  }

  Future<void> _onCargarPendientes(
      CargarPendientes event,
      Emitter<VisitAuthorizationState> emit,
      ) async {
    emit(VisitAuthorizationLoading());
    try {
      final pendientes = await _repository.obtenerPendientes();
      AppLogger.info(_modulo, 'Pendientes cargados: ${pendientes.length}');
      emit(PendientesLoaded(pendientes: pendientes));
    } on AppException catch (e) {
      emit(VisitAuthorizationError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error al cargar pendientes: $e');
      emit(const VisitAuthorizationError(
        mensaje: 'No fue posible obtener las solicitudes. Intente nuevamente',
      ));
    }
  }

  Future<void> _onCargarDetalle(
      CargarDetalle event,
      Emitter<VisitAuthorizationState> emit,
      ) async {
    emit(VisitAuthorizationLoading());
    try {
      final solicitud = await _repository.obtenerDetalle(event.idSolicitud);
      emit(DetalleLoaded(solicitud: solicitud));
    } on AppException catch (e) {
      emit(VisitAuthorizationError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error al cargar detalle: $e');
      emit(const VisitAuthorizationError(
        mensaje: 'No fue posible obtener el detalle. Intente nuevamente',
      ));
    }
  }

  Future<void> _onAutorizar(
      AutorizarSolicitud event,
      Emitter<VisitAuthorizationState> emit,
      ) async {
    emit(VisitAuthorizationLoading());
    try {
      await _repository.autorizar(event.idSolicitud);
      AppLogger.info(_modulo, 'Solicitud autorizada: ${event.idSolicitud}');
      emit(const AutorizacionSuccess(
        mensaje: 'Su solicitud ha sido autorizada. Ya puedes enviar el código QR a tu visitante',
      ));
    } on AppException catch (e) {
      emit(VisitAuthorizationError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error al autorizar: $e');
      emit(const VisitAuthorizationError(
        mensaje: 'No fue posible autorizar la solicitud. Intente nuevamente',
      ));
    }
  }

  Future<void> _onRechazar(
      RechazarSolicitud event,
      Emitter<VisitAuthorizationState> emit,
      ) async {
    emit(VisitAuthorizationLoading());
    try {
      await _repository.rechazar(event.idSolicitud, event.motivo);
      AppLogger.info(_modulo, 'Solicitud rechazada: ${event.idSolicitud}');
      emit(const AutorizacionSuccess(
        mensaje: 'Su solicitud fue rechazada',
      ));
    } on AppException catch (e) {
      emit(VisitAuthorizationError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error al rechazar: $e');
      emit(const VisitAuthorizationError(
        mensaje: 'No fue posible rechazar la solicitud. Intente nuevamente',
      ));
    }
  }
}