// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : qr_generation_bloc.dart
// Módulo    : features/qr_generation/bloc
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Gestor de estado de generación QR — RF-021, RF-032
// =============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../business/qr_generation_validator.dart';
import '../data/qr_generation_model.dart';
import '../data/qr_generation_repository.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/errors/app_logger.dart';

// ── Eventos ──────────────────────────────────────────────────────────────────
abstract class QrGenerationEvent extends Equatable {
  const QrGenerationEvent();

  @override
  List<Object?> get props => [];
}

class CargarQrSolicitud extends QrGenerationEvent {
  final int idSolicitud;

  const CargarQrSolicitud({required this.idSolicitud});

  @override
  List<Object?> get props => [idSolicitud];
}

class EnviarQrVisitante extends QrGenerationEvent {
  final int idSolicitud;

  const EnviarQrVisitante({required this.idSolicitud});

  @override
  List<Object?> get props => [idSolicitud];
}

class ReenviarQrVisitante extends QrGenerationEvent {
  final int idSolicitud;
  final QrGenerationModel qr;

  const ReenviarQrVisitante({
    required this.idSolicitud,
    required this.qr,
  });

  @override
  List<Object?> get props => [idSolicitud, qr];
}

// ── Estados ──────────────────────────────────────────────────────────────────
abstract class QrGenerationState extends Equatable {
  const QrGenerationState();

  @override
  List<Object?> get props => [];
}

class QrGenerationInitial extends QrGenerationState {}

class QrGenerationLoading extends QrGenerationState {}

class QrLoaded extends QrGenerationState {
  final List<QrGenerationModel> qrList;

  const QrLoaded({required this.qrList});

  @override
  List<Object?> get props => [qrList];
}

class QrActionSuccess extends QrGenerationState {
  final String mensaje;

  const QrActionSuccess({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}

class QrGenerationError extends QrGenerationState {
  final String mensaje;

  const QrGenerationError({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}

// ── Bloc ─────────────────────────────────────────────────────────────────────
class QrGenerationBloc extends Bloc<QrGenerationEvent, QrGenerationState> {
  static const String _modulo = 'QR_GENERATION_BLOC';
  final QrGenerationRepository _repository;

  QrGenerationBloc({QrGenerationRepository? repository})
      : _repository = repository ?? QrGenerationRepository(),
        super(QrGenerationInitial()) {
    on<CargarQrSolicitud>(_onCargarQr);
    on<EnviarQrVisitante>(_onEnviarQr);
    on<ReenviarQrVisitante>(_onReenviarQr);
  }

  Future<void> _onCargarQr(
      CargarQrSolicitud event,
      Emitter<QrGenerationState> emit,
      ) async {
    emit(QrGenerationLoading());
    try {
      final qrList = await _repository.obtenerQrSolicitud(event.idSolicitud);
      emit(QrLoaded(qrList: qrList));
    } on AppException catch (e) {
      emit(QrGenerationError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error al cargar QR: $e');
      emit(const QrGenerationError(
        mensaje: 'No fue posible obtener el QR. Intente nuevamente',
      ));
    }
  }

  Future<void> _onEnviarQr(
      EnviarQrVisitante event,
      Emitter<QrGenerationState> emit,
      ) async {
    emit(QrGenerationLoading());
    try {
      await _repository.enviarQr(event.idSolicitud);
      AppLogger.info(_modulo, 'QR enviado: ${event.idSolicitud}');
      emit(const QrActionSuccess(
        mensaje: 'Se envió el pase QR con instrucciones de acceso.',
      ));
    } on AppException catch (e) {
      emit(QrGenerationError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error al enviar QR: $e');
      emit(const QrGenerationError(
        mensaje: 'No fue posible enviar el pase. Intente más tarde.',
      ));
    }
  }

  Future<void> _onReenviarQr(
      ReenviarQrVisitante event,
      Emitter<QrGenerationState> emit,
      ) async {
    emit(QrGenerationLoading());
    try {
      QrGenerationValidator.validarReenvio(event.qr);
      await _repository.reenviarQr(event.idSolicitud);
      AppLogger.info(_modulo, 'QR reenviado: ${event.idSolicitud}');
      emit(const QrActionSuccess(
        mensaje: 'Se envió el pase QR con instrucciones de acceso.',
      ));
    } on ValidationException catch (e) {
      emit(QrGenerationError(mensaje: e.mensaje));
    } on AppException catch (e) {
      emit(QrGenerationError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error al reenviar QR: $e');
      emit(const QrGenerationError(
        mensaje: 'No fue posible reenviar el pase. Intente más tarde.',
      ));
    }
  }
}