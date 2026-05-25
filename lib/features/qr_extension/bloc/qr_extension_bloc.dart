// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : qr_extension_bloc.dart
// Módulo    : features/qr_extension/bloc
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Gestor de estado de extensión QR — RF-018, RF-038
// =============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/qr_extension_model.dart';
import '../data/qr_extension_repository.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/errors/app_logger.dart';

// ── Eventos ──────────────────────────────────────────────────────────────────
abstract class QrExtensionEvent extends Equatable {
  const QrExtensionEvent();

  @override
  List<Object?> get props => [];
}

class ExtenderVigenciaQr extends QrExtensionEvent {
  final int idSolicitud;
  final int minutosExtra;

  const ExtenderVigenciaQr({
    required this.idSolicitud,
    required this.minutosExtra,
  });

  @override
  List<Object?> get props => [idSolicitud, minutosExtra];
}

class ResetExtension extends QrExtensionEvent {}

// ── Estados ──────────────────────────────────────────────────────────────────
abstract class QrExtensionState extends Equatable {
  const QrExtensionState();

  @override
  List<Object?> get props => [];
}

class QrExtensionInitial extends QrExtensionState {}

class QrExtensionLoading extends QrExtensionState {}

class QrExtensionSuccess extends QrExtensionState {
  final QrExtensionModel resultado;

  const QrExtensionSuccess({required this.resultado});

  @override
  List<Object?> get props => [resultado];
}

class QrExtensionError extends QrExtensionState {
  final String mensaje;

  const QrExtensionError({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}

// ── Bloc ─────────────────────────────────────────────────────────────────────
class QrExtensionBloc extends Bloc<QrExtensionEvent, QrExtensionState> {
  static const String _modulo = 'QR_EXTENSION_BLOC';
  final QrExtensionRepository _repository;

  QrExtensionBloc({QrExtensionRepository? repository})
      : _repository = repository ?? QrExtensionRepository(),
        super(QrExtensionInitial()) {
    on<ExtenderVigenciaQr>(_onExtender);
    on<ResetExtension>(_onReset);
  }

  Future<void> _onExtender(
      ExtenderVigenciaQr event,
      Emitter<QrExtensionState> emit,
      ) async {
    emit(QrExtensionLoading());
    try {
      final resultado = await _repository.extenderQr(
        idSolicitud: event.idSolicitud,
        minutosExtra: event.minutosExtra,
      );
      AppLogger.info(_modulo, 'QR extendido: ${event.idSolicitud}');
      emit(QrExtensionSuccess(resultado: resultado));
    } on AppException catch (e) {
      emit(QrExtensionError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error inesperado: $e');
      emit(const QrExtensionError(
        mensaje: 'No fue posible extender la vigencia del QR.',
      ));
    }
  }

  void _onReset(
      ResetExtension event,
      Emitter<QrExtensionState> emit,
      ) {
    emit(QrExtensionInitial());
  }
}