// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : visit_confirmation_bloc.dart
// Módulo    : features/visit_confirmation/bloc
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Gestor de estado de confirmación — RF-026, RF-051, RF-052
// =============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/confirmation_model.dart';
import '../data/confirmation_repository.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/errors/app_logger.dart';

// ── Eventos ──────────────────────────────────────────────────────────────────
abstract class VisitConfirmationEvent extends Equatable {
  const VisitConfirmationEvent();

  @override
  List<Object?> get props => [];
}

class CargarVisitasActivas extends VisitConfirmationEvent {}

class ConfirmarLlegadaArea extends VisitConfirmationEvent {
  final int idSolicitud;

  const ConfirmarLlegadaArea({required this.idSolicitud});

  @override
  List<Object?> get props => [idSolicitud];
}

class ConfirmarSalidaArea extends VisitConfirmationEvent {
  final int idSolicitud;

  const ConfirmarSalidaArea({required this.idSolicitud});

  @override
  List<Object?> get props => [idSolicitud];
}

// ── Estados ──────────────────────────────────────────────────────────────────
abstract class VisitConfirmationState extends Equatable {
  const VisitConfirmationState();

  @override
  List<Object?> get props => [];
}

class VisitConfirmationInitial extends VisitConfirmationState {}

class VisitConfirmationLoading extends VisitConfirmationState {}

class VisitasActivasLoaded extends VisitConfirmationState {
  final List<ConfirmationModel> visitas;

  const VisitasActivasLoaded({required this.visitas});

  @override
  List<Object?> get props => [visitas];
}

class ConfirmationSuccess extends VisitConfirmationState {
  final String mensaje;
  final ConfirmationModel confirmacion;

  const ConfirmationSuccess({
    required this.mensaje,
    required this.confirmacion,
  });

  @override
  List<Object?> get props => [mensaje, confirmacion];
}

class VisitConfirmationError extends VisitConfirmationState {
  final String mensaje;

  const VisitConfirmationError({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}

// ── Bloc ─────────────────────────────────────────────────────────────────────
class VisitConfirmationBloc
    extends Bloc<VisitConfirmationEvent, VisitConfirmationState> {
  static const String _modulo = 'VISIT_CONFIRMATION_BLOC';
  final ConfirmationRepository _repository;

  VisitConfirmationBloc({ConfirmationRepository? repository})
      : _repository = repository ?? ConfirmationRepository(),
        super(VisitConfirmationInitial()) {
    on<CargarVisitasActivas>(_onCargarVisitasActivas);
    on<ConfirmarLlegadaArea>(_onConfirmarLlegada);
    on<ConfirmarSalidaArea>(_onConfirmarSalida);
  }

  Future<void> _onCargarVisitasActivas(
      CargarVisitasActivas event,
      Emitter<VisitConfirmationState> emit,
      ) async {
    emit(VisitConfirmationLoading());
    try {
      final visitas = await _repository.obtenerVisitasActivas();
      emit(VisitasActivasLoaded(visitas: visitas));
    } on AppException catch (e) {
      emit(VisitConfirmationError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error al cargar visitas activas: $e');
      emit(const VisitConfirmationError(
        mensaje: 'No fue posible obtener las visitas activas',
      ));
    }
  }

  Future<void> _onConfirmarLlegada(
      ConfirmarLlegadaArea event,
      Emitter<VisitConfirmationState> emit,
      ) async {
    emit(VisitConfirmationLoading());
    try {
      final confirmacion =
      await _repository.confirmarLlegadaArea(event.idSolicitud);
      AppLogger.info(_modulo, 'Llegada confirmada: ${event.idSolicitud}');
      emit(ConfirmationSuccess(
        mensaje: 'Visita confirmada en oficina',
        confirmacion: confirmacion,
      ));
    } on AppException catch (e) {
      emit(VisitConfirmationError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error al confirmar llegada: $e');
      emit(const VisitConfirmationError(
        mensaje: 'No fue posible registrar llegada',
      ));
    }
  }

  Future<void> _onConfirmarSalida(
      ConfirmarSalidaArea event,
      Emitter<VisitConfirmationState> emit,
      ) async {
    emit(VisitConfirmationLoading());
    try {
      final confirmacion =
      await _repository.confirmarSalidaArea(event.idSolicitud);
      AppLogger.info(_modulo, 'Salida confirmada: ${event.idSolicitud}');
      emit(ConfirmationSuccess(
        mensaje: 'Salida del visitante registrada correctamente',
        confirmacion: confirmacion,
      ));
    } on AppException catch (e) {
      emit(VisitConfirmationError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error al confirmar salida: $e');
      emit(const VisitConfirmationError(
        mensaje: 'No fue posible registrar salida',
      ));
    }
  }
}