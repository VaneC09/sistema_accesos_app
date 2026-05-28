// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : consulta_bloc.dart
// Módulo    : features/visit_request/bloc
// Autor     : Omega Company
// Fecha     : 2026-05-28
// Versión   : 1.0.0
// Descripción: Gestor de estado para visita espontánea de consulta — RF-014
// =============================================================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../core/errors/app_logger.dart';
import '../data/consulta_model.dart';
import '../data/consulta_repository.dart';

// ── Eventos ──────────────────────────────────────────────────────────────────

abstract class ConsultaEvent extends Equatable {
  const ConsultaEvent();

  @override
  List<Object?> get props => [];
}

class ConsultaSubmitted extends ConsultaEvent {
  final ConsultaRequestModel consulta;

  const ConsultaSubmitted({required this.consulta});

  @override
  List<Object?> get props => [consulta];
}

class ConsultaReset extends ConsultaEvent {}

// ── Estados ──────────────────────────────────────────────────────────────────

abstract class ConsultaState extends Equatable {
  const ConsultaState();

  @override
  List<Object?> get props => [];
}

class ConsultaInitial extends ConsultaState {}

class ConsultaLoading extends ConsultaState {}

class ConsultaSuccess extends ConsultaState {
  final ConsultaResponseModel resultado;

  const ConsultaSuccess({required this.resultado});

  @override
  List<Object?> get props => [resultado];
}

class ConsultaError extends ConsultaState {
  final String mensaje;

  const ConsultaError({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}

// ── Bloc ─────────────────────────────────────────────────────────────────────

class ConsultaBloc extends Bloc<ConsultaEvent, ConsultaState> {
  final ConsultaRepository _repository;
  static const String _modulo = 'CONSULTA_BLOC';

  ConsultaBloc({ConsultaRepository? repository})
      : _repository = repository ?? ConsultaRepository(),
        super(ConsultaInitial()) {
    on<ConsultaSubmitted>(_onConsultaSubmitted);
    on<ConsultaReset>(_onConsultaReset);
  }

  Future<void> _onConsultaSubmitted(
      ConsultaSubmitted event,
      Emitter<ConsultaState> emit,
      ) async {
    try {
      emit(ConsultaLoading());

      final resultado = await _repository.registrarConsulta(event.consulta);

      AppLogger.info(
        _modulo,
        'Visita de consulta registrada: ${resultado.folio}',
      );

      emit(ConsultaSuccess(resultado: resultado));
    } on AppException catch (e) {
      emit(ConsultaError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error inesperado al registrar consulta: $e');
      emit(
        const ConsultaError(
          mensaje:
          'No fue posible registrar la visita de consulta. Intente nuevamente',
        ),
      );
    }
  }

  void _onConsultaReset(
      ConsultaReset event,
      Emitter<ConsultaState> emit,
      ) {
    emit(ConsultaInitial());
  }
}