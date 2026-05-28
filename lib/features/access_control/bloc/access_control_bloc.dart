// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : access_control_bloc.dart
// Módulo    : features/access_control/bloc
// Autor     : Omega Company
// Fecha     : 2026-05-27
// Versión   : 1.1.0
// Descripción: Gestor de estado de control de acceso con flujos de confirmación — RF-022, RF-025
// =============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../business/qr_validator.dart';
import '../data/access_model.dart';
import '../data/access_repository.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/errors/app_logger.dart';

// ── Eventos ──────────────────────────────────────────────────────────────────
abstract class AccessControlEvent extends Equatable {
  const AccessControlEvent();

  @override
  List<Object?> get props => [];
}

class EscanearQr extends AccessControlEvent {
  final String codigoQr;
  final String telefono;
  final String area;

  const EscanearQr({
    required this.codigoQr,
    required this.telefono,
    required this.area,
  });

  @override
  List<Object?> get props => [codigoQr, telefono, area];
}

class RegistroManual extends AccessControlEvent {
  final String codigoNumerico;
  final String telefono;
  final String area;

  const RegistroManual({
    required this.codigoNumerico,
    required this.telefono,
    required this.area,
  });

  @override
  List<Object?> get props => [codigoNumerico, telefono, area];
}

class CargarVisitasHoy extends AccessControlEvent {
  final String telefono;

  const CargarVisitasHoy({required this.telefono});

  @override
  List<Object?> get props => [telefono];
}

class ResetAcceso extends AccessControlEvent {}

/// Evento para registrar explícitamente la entrada de la visita
class RegistrarEntrada extends AccessControlEvent {
  final int idQr;
  final String telefono;
  final String area;

  const RegistrarEntrada({required this.idQr, required this.telefono, required this.area});

  @override
  List<Object?> get props => [idQr, telefono, area];
}

/// Evento para registrar explícitamente la salida de la visita
class RegistrarSalida extends AccessControlEvent {
  final int idQr;
  final String telefono;
  final String area;

  const RegistrarSalida({required this.idQr, required this.telefono, required this.area});

  @override
  List<Object?> get props => [idQr, telefono, area];
}

// ── Estados ──────────────────────────────────────────────────────────────────
abstract class AccessControlState extends Equatable {
  const AccessControlState();

  @override
  List<Object?> get props => [];
}

class AccessControlInitial extends AccessControlState {}

class AccessControlLoading extends AccessControlState {}

class QrEscaneadoSuccess extends AccessControlState {
  final QrScanResultModel resultado;

  const QrEscaneadoSuccess({required this.resultado});

  @override
  List<Object?> get props => [resultado];
}

class VisitasHoyLoaded extends AccessControlState {
  final List<VisitaHoyModel> visitas;

  const VisitasHoyLoaded({required this.visitas});

  @override
  List<Object?> get props => [visitas];
}

class AccessControlError extends AccessControlState {
  final String mensaje;

  const AccessControlError({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}

/// Estado emitido cuando el backend procesa exitosamente la entrada o la salida
class AccesoRegistrado extends AccessControlState {
  final String mensaje;
  final String tipo; // 'entrada' o 'salida'

  const AccesoRegistrado({required this.mensaje, required this.tipo});

  @override
  List<Object?> get props => [mensaje, tipo];
}

// ── Bloc ─────────────────────────────────────────────────────────────────────
class AccessControlBloc extends Bloc<AccessControlEvent, AccessControlState> {
  static const String _modulo = 'ACCESS_CONTROL_BLOC';
  final AccessRepository _repository;

  AccessControlBloc({AccessRepository? repository})
      : _repository = repository ?? AccessRepository(),
        super(AccessControlInitial()) {
    on<EscanearQr>(_onEscanearQr);
    on<RegistroManual>(_onRegistroManual);
    on<CargarVisitasHoy>(_onCargarVisitasHoy);
    on<ResetAcceso>(_onReset);
    on<RegistrarEntrada>(_onRegistrarEntrada);
    on<RegistrarSalida>(_onRegistrarSalida);
  }

  Future<void> _onEscanearQr(
      EscanearQr event,
      Emitter<AccessControlState> emit,
      ) async {
    try {
      QrValidator.validarCodigoQr(event.codigoQr);
      QrValidator.validarTelefonoVigilante(event.telefono);

      emit(AccessControlLoading());

      final resultado = await _repository.escanearQr(
        codigoQr: event.codigoQr,
        telefono: event.telefono,
        area: event.area,
      );

      AppLogger.info(
        _modulo,
        'QR escaneado — acceso: ${resultado.accesoConcedido}',
      );
      emit(QrEscaneadoSuccess(resultado: resultado));
    } on ValidationException catch (e) {
      emit(AccessControlError(mensaje: e.mensaje));
    } on ExclusionListException catch (e) {
      AppLogger.warning(_modulo, 'Visitante en lista de exclusión');
      emit(AccessControlError(mensaje: e.mensaje));
    } on AppException catch (e) {
      emit(AccessControlError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error inesperado al escanear: $e');
      emit(const AccessControlError(
        mensaje: 'No fue posible validar el QR. Intente nuevamente',
      ));
    }
  }

  Future<void> _onRegistroManual(
      RegistroManual event,
      Emitter<AccessControlState> emit,
      ) async {
    try {
      QrValidator.validarCodigoNumerico(event.codigoNumerico);
      QrValidator.validarTelefonoVigilante(event.telefono);

      emit(AccessControlLoading());

      final resultado = await _repository.registroManual(
        codigoNumerico: event.codigoNumerico,
        telefono: event.telefono,
        area: event.area,
      );

      AppLogger.info(
        _modulo,
        'Registro manual — acceso: ${resultado.accesoConcedido}',
      );
      emit(QrEscaneadoSuccess(resultado: resultado));
    } on ValidationException catch (e) {
      emit(AccessControlError(mensaje: e.mensaje));
    } on AppException catch (e) {
      emit(AccessControlError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error inesperado en registro manual: $e');
      emit(const AccessControlError(
        mensaje: 'No fue posible registrar el acceso. Intente nuevamente',
      ));
    }
  }

  Future<void> _onCargarVisitasHoy(
      CargarVisitasHoy event,
      Emitter<AccessControlState> emit,
      ) async {
    try {
      emit(AccessControlLoading());

      final visitas = await _repository.obtenerVisitasHoy(
        telefono: event.telefono,
      );

      AppLogger.info(_modulo, 'Visitas del día cargadas: ${visitas.length}');
      emit(VisitasHoyLoaded(visitas: visitas));
    } on AppException catch (e) {
      emit(AccessControlError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error al cargar visitas: $e');
      emit(const AccessControlError(
        mensaje: 'No fue posible obtener las visitas. Intente nuevamente',
      ));
    }
  }

  void _onReset(
      ResetAcceso event,
      Emitter<AccessControlState> emit,
      ) {
    emit(AccessControlInitial());
  }

  Future<void> _onRegistrarEntrada(
      RegistrarEntrada event,
      Emitter<AccessControlState> emit,
      ) async {
    try {
      emit(AccessControlLoading());
      await _repository.registrarEntrada(
        idQr: event.idQr,
        telefono: event.telefono,
        area: event.area,
      );
      AppLogger.info(_modulo, 'Entrada registrada — id_qr: ${event.idQr}');
      emit(const AccesoRegistrado(mensaje: 'Entrada registrada correctamente', tipo: 'entrada'));
    } on AppException catch (e) {
      emit(AccessControlError(mensaje: e.mensaje));
    } catch (e) {
      emit(const AccessControlError(mensaje: 'No fue posible registrar la entrada'));
    }
  }

  Future<void> _onRegistrarSalida(
      RegistrarSalida event,
      Emitter<AccessControlState> emit,
      ) async {
    try {
      emit(AccessControlLoading());
      await _repository.registrarSalida(
        idQr: event.idQr,
        telefono: event.telefono,
        area: event.area,
      );
      AppLogger.info(_modulo, 'Salida registrada — id_qr: ${event.idQr}');
      emit(const AccesoRegistrado(mensaje: 'Salida registrada correctamente', tipo: 'salida'));
    } on AppException catch (e) {
      emit(AccessControlError(mensaje: e.mensaje));
    } catch (e) {
      emit(const AccessControlError(mensaje: 'No fue posible registrar la salida'));
    }
  }
}