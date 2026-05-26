// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : visit_request_bloc.dart
// Módulo    : features/visit_request/bloc
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Gestor de estado de solicitudes — RF-013, RF-014, RF-015
// =============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../business/visit_request_validator.dart';
import '../data/visit_request_model.dart';
import '../data/visit_request_repository.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/errors/app_logger.dart';

// ── Eventos ──────────────────────────────────────────────────────────────────
abstract class VisitRequestEvent extends Equatable {
  const VisitRequestEvent();

  @override
  List<Object?> get props => [];
}

class CargarCatalogos extends VisitRequestEvent {}

class VisitRequestSubmitted extends VisitRequestEvent {
  final VisitRequestModel solicitud;

  const VisitRequestSubmitted({required this.solicitud});

  @override
  List<Object?> get props => [solicitud];
}

class CargarMisSolicitudes extends VisitRequestEvent {
  final String? estado;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const CargarMisSolicitudes({
    this.estado,
    this.fechaInicio,
    this.fechaFin,
  });

  @override
  List<Object?> get props => [estado, fechaInicio, fechaFin];
}

class CancelarSolicitud extends VisitRequestEvent {
  final int idSolicitud;

  const CancelarSolicitud({required this.idSolicitud});

  @override
  List<Object?> get props => [idSolicitud];
}

class EnviarQr extends VisitRequestEvent {
  final int idSolicitud;

  const EnviarQr({required this.idSolicitud});

  @override
  List<Object?> get props => [idSolicitud];
}

class ExtenderQr extends VisitRequestEvent {
  final int idSolicitud;

  const ExtenderQr({required this.idSolicitud});

  @override
  List<Object?> get props => [idSolicitud];
}

class VisitRequestReset extends VisitRequestEvent {}

// ── Estados ──────────────────────────────────────────────────────────────────
abstract class VisitRequestState extends Equatable {
  const VisitRequestState();

  @override
  List<Object?> get props => [];
}

class VisitRequestInitial extends VisitRequestState {}

class VisitRequestLoading extends VisitRequestState {}

class CatalogosLoaded extends VisitRequestState {
  final List<CatalogoModel> tiposVisita;
  final List<CatalogoModel> departamentos;

  const CatalogosLoaded({
    required this.tiposVisita,
    required this.departamentos,
  });

  @override
  List<Object?> get props => [tiposVisita, departamentos];
}

class VisitRequestSuccess extends VisitRequestState {
  final String folio;

  const VisitRequestSuccess({required this.folio});

  @override
  List<Object?> get props => [folio];
}

class MisSolicitudesLoaded extends VisitRequestState {
  final List<VisitRequestModel> solicitudes;

  const MisSolicitudesLoaded({required this.solicitudes});

  @override
  List<Object?> get props => [solicitudes];
}

class VisitRequestActionSuccess extends VisitRequestState {
  final String mensaje;

  const VisitRequestActionSuccess({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}

class VisitRequestError extends VisitRequestState {
  final String mensaje;

  const VisitRequestError({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}

// ── Bloc ─────────────────────────────────────────────────────────────────────
class VisitRequestBloc extends Bloc<VisitRequestEvent, VisitRequestState> {
  static const String _modulo = 'VISIT_REQUEST_BLOC';
  final VisitRequestRepository _repository;

  VisitRequestBloc({VisitRequestRepository? repository})
      : _repository = repository ?? VisitRequestRepository(),
        super(VisitRequestInitial()) {
    on<CargarCatalogos>(_onCargarCatalogos);
    on<VisitRequestSubmitted>(_onSubmitted);
    on<CargarMisSolicitudes>(_onCargarMisSolicitudes);
    on<CancelarSolicitud>(_onCancelarSolicitud);
    on<EnviarQr>(_onEnviarQr);
    on<ExtenderQr>(_onExtenderQr);
    on<VisitRequestReset>(_onReset);
  }

  Future<void> _onCargarCatalogos(
      CargarCatalogos event,
      Emitter<VisitRequestState> emit,
      ) async {
    emit(VisitRequestLoading());
    try {
      final tiposVisita = await _repository.obtenerTiposVisita();
      final departamentos = await _repository.obtenerDepartamentos();
      emit(CatalogosLoaded(
        tiposVisita: tiposVisita,
        departamentos: departamentos,
      ));
    } on AppException catch (e) {
      AppLogger.error(_modulo, 'Error cargando catálogos: ${e.mensaje}');
      emit(VisitRequestError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error inesperado catálogos: $e');
      emit(const VisitRequestError(
        mensaje: 'No fue posible cargar los datos. Intente nuevamente',
      ));
    }
  }

  Future<void> _onSubmitted(
      VisitRequestSubmitted event,
      Emitter<VisitRequestState> emit,
      ) async {
    emit(VisitRequestLoading());
    try {
      // Validaciones de negocio
      VisitRequestValidator.validarSolicitud(
        lugarDestino: event.solicitud.lugarDestino,
        motivoVisita: event.solicitud.motivoVisita,
        fechaVisita: event.solicitud.fechaVisita,
        tipoVisita: event.solicitud.tipoVisita,
      );

      for (final visitante in event.solicitud.visitantes) {
        VisitRequestValidator.validarNombre(visitante.nombre);
        VisitRequestValidator.validarCorreo(visitante.correo);
      }

      if (event.solicitud.esGrupal) {
        final correos = event.solicitud.visitantes
            .map((v) => v.correo)
            .toList();
        VisitRequestValidator.validarCorreosDuplicados(correos);
      }

      final resultado = await _repository.crearSolicitud(event.solicitud);
      final folio = resultado.folio ?? 'VIS-${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 13)}';
      AppLogger.info(_modulo, 'Solicitud creada: $folio');
      emit(VisitRequestSuccess(folio: folio));
    } on ValidationException catch (e) {
      emit(VisitRequestError(mensaje: e.mensaje));
    } on AppException catch (e) {
      AppLogger.error(_modulo, 'Error creando solicitud: ${e.mensaje}');
      emit(VisitRequestError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error inesperado: $e');
      emit(const VisitRequestError(
        mensaje: 'No fue posible crear la solicitud. Intente nuevamente',
      ));
    }
  }

  Future<void> _onCargarMisSolicitudes(
      CargarMisSolicitudes event,
      Emitter<VisitRequestState> emit,
      ) async {
    emit(VisitRequestLoading());
    try {
      final solicitudes = await _repository.obtenerMisSolicitudes(
        estado: event.estado,
        fechaInicio: event.fechaInicio,
        fechaFin: event.fechaFin,
      );
      emit(MisSolicitudesLoaded(solicitudes: solicitudes));
    } on AppException catch (e) {
      emit(VisitRequestError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error cargando solicitudes: $e');
      emit(const VisitRequestError(
        mensaje: 'No fue posible obtener las solicitudes. Intente nuevamente',
      ));
    }
  }

  Future<void> _onCancelarSolicitud(
      CancelarSolicitud event,
      Emitter<VisitRequestState> emit,
      ) async {
    emit(VisitRequestLoading());
    try {
      await _repository.cancelarSolicitud(event.idSolicitud);
      AppLogger.info(_modulo, 'Solicitud cancelada: ${event.idSolicitud}');
      emit(const VisitRequestActionSuccess(
        mensaje: 'Solicitud cancelada correctamente',
      ));
    } on AppException catch (e) {
      emit(VisitRequestError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error cancelando solicitud: $e');
      emit(const VisitRequestError(
        mensaje: 'No fue posible cancelar la solicitud. Intente nuevamente',
      ));
    }
  }

  Future<void> _onEnviarQr(
      EnviarQr event,
      Emitter<VisitRequestState> emit,
      ) async {
    emit(VisitRequestLoading());
    try {
      await _repository.enviarQr(event.idSolicitud);
      AppLogger.info(_modulo, 'QR enviado: ${event.idSolicitud}');
      emit(const VisitRequestActionSuccess(
        mensaje: 'Se envió el pase QR con instrucciones de acceso.',
      ));
    } on AppException catch (e) {
      emit(VisitRequestError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error enviando QR: $e');
      emit(const VisitRequestError(
        mensaje: 'No fue posible enviar el pase. Intente más tarde.',
      ));
    }
  }

  Future<void> _onExtenderQr(
      ExtenderQr event,
      Emitter<VisitRequestState> emit,
      ) async {
    emit(VisitRequestLoading());
    try {
      await _repository.extenderQr(event.idSolicitud);
      AppLogger.info(_modulo, 'QR extendido: ${event.idSolicitud}');
      emit(const VisitRequestActionSuccess(
        mensaje: 'La vigencia del pase QR ha sido extendida.',
      ));
    } on AppException catch (e) {
      emit(VisitRequestError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error extendiendo QR: $e');
      emit(const VisitRequestError(
        mensaje: 'No fue posible extender la vigencia del QR.',
      ));
    }
  }

  void _onReset(
      VisitRequestReset event,
      Emitter<VisitRequestState> emit,
      ) {
    emit(VisitRequestInitial());
  }
}