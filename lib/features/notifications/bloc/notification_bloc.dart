/// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : notification_bloc.dart
// Módulo    : features/notifications/bloc
// Autor     : Omega Company
// Fecha     : 2026-05-29
// Versión   : 2.0.0
// Descripción: Extiende v1.0.0 — agrega polling, NuevaNotificacionRecibida
//              y AutorizarExtensionQr — RF-023, RF-025
//
// Cambios respecto a v1:
//  + IniciarPollingNotificaciones / DetenerPollingNotificaciones
//  + _TickPolling (evento interno)
//  + MarcarNotificacionLeida  (persiste en backend; MarcarComoLeida se conserva)
//  + MarcarTodasLeidas
//  + AutorizarExtensionQr
//  + Estado NuevaNotificacionRecibida
//  + Estado ExtensionQrResultado
//  Conserva: CargarNotificaciones, NotificacionRecibida, MarcarComoLeida,
//            LimpiarNotificaciones, NotificacionesLoaded, NotificationError
// =============================================================================

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/notification_model.dart';
import '../data/notification_repository.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/errors/app_logger.dart';
import '../../../core/models/paginacion_model.dart';

// ── Eventos ──────────────────────────────────────────────────────────────────

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

// ── Eventos que ya existían (sin cambios) ────────────────────────────────────

class CargarNotificaciones extends NotificationEvent {
  final int pagina;
  final String? estado;

  const CargarNotificaciones({this.pagina = 1, this.estado});

  @override
  List<Object?> get props => [pagina, estado];
}

class NotificacionRecibida extends NotificationEvent {
  final NotificationModel notificacion;
  const NotificacionRecibida({required this.notificacion});
  @override
  List<Object?> get props => [notificacion];
}

/// Alias original — conservado para no romper pantallas existentes.
class MarcarComoLeida extends NotificationEvent {
  final String idNotificacion;
  const MarcarComoLeida({required this.idNotificacion});
  @override
  List<Object?> get props => [idNotificacion];
}

class LimpiarNotificaciones extends NotificationEvent {}

// ── Eventos nuevos ────────────────────────────────────────────────────────────

/// Inicia el polling periódico (llama a la API cada [intervalo]).
class IniciarPollingNotificaciones extends NotificationEvent {
  final Duration intervalo;
  const IniciarPollingNotificaciones({
    this.intervalo = const Duration(seconds: 15),
  });
  @override
  List<Object?> get props => [intervalo];
}

/// Detiene el polling (ej. al cerrar sesión).
class DetenerPollingNotificaciones extends NotificationEvent {}

/// Polling para vigilante vía /vigilante/notificaciones (sin Sanctum).
class IniciarPollingVigilante extends NotificationEvent {
  final String telefono;
  final Duration intervalo;

  const IniciarPollingVigilante({
    required this.telefono,
    this.intervalo = const Duration(seconds: 15),
  });

  @override
  List<Object?> get props => [telefono, intervalo];
}

/// Igual que [MarcarComoLeida] pero también persiste en el backend.
class MarcarNotificacionLeida extends NotificationEvent {
  final String idNotificacion;
  const MarcarNotificacionLeida({required this.idNotificacion});
  @override
  List<Object?> get props => [idNotificacion];
}

/// Marca todas las notificaciones como leídas en backend y estado local.
class MarcarTodasLeidas extends NotificationEvent {}

/// El anfitrión autoriza la extensión del QR de la solicitud [idSolicitud].
class AutorizarExtensionQr extends NotificationEvent {
  final int idSolicitud;
  const AutorizarExtensionQr({required this.idSolicitud});
  @override
  List<Object?> get props => [idSolicitud];
}

/// Evento interno del timer — no usar desde la UI.
class _TickPolling extends NotificationEvent {}

// ── Estados ──────────────────────────────────────────────────────────────────

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

// ── Estados que ya existían (sin cambios) ────────────────────────────────────

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificacionesLoaded extends NotificationState {
  final List<NotificationModel> notificaciones;
  final int noLeidas;
  final PaginacionModel paginacion;

  const NotificacionesLoaded({
    required this.notificaciones,
    required this.noLeidas,
    required this.paginacion,
  });

  @override
  List<Object?> get props => [notificaciones, noLeidas, paginacion];
}

class NotificationError extends NotificationState {
  final String mensaje;
  const NotificationError({required this.mensaje});
  @override
  List<Object?> get props => [mensaje];
}

// ── Estados nuevos ────────────────────────────────────────────────────────────

/// Se emite cuando el polling detecta una notificación nueva de tipo
/// [visitante_ingreso], [solicitud_extension] o [qr_expirado_tolerancia].
class NuevaNotificacionRecibida extends NotificationState {
  final NotificationModel notificacion;
  final List<NotificationModel> todasLasNotificaciones;
  final int noLeidas;
  final PaginacionModel paginacion;

  const NuevaNotificacionRecibida({
    required this.notificacion,
    required this.todasLasNotificaciones,
    required this.noLeidas,
    required this.paginacion,
  });

  bool get esIngreso => notificacion.tipo == TipoNotificacion.visitanteIngreso;

  bool get esSolicitudExtension =>
      notificacion.tipo == TipoNotificacion.solicitudExtension ||
      notificacion.tipo == TipoNotificacion.qrExpiradoTolerancia;

  bool get esQrExtendido => notificacion.tipo == TipoNotificacion.qrExtendido;

  @override
  List<Object?> get props =>
      [notificacion, todasLasNotificaciones, noLeidas, paginacion];
}

/// Resultado de [AutorizarExtensionQr].
class ExtensionQrResultado extends NotificationState {
  final bool exito;
  final String mensaje;
  const ExtensionQrResultado({required this.exito, required this.mensaje});
  @override
  List<Object?> get props => [exito, mensaje];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  static const String _modulo = 'NOTIFICATION_BLOC';

  final NotificationRepository _repository;

  /// Estado local en memoria (igual que v1).
  final List<NotificationModel> _notificaciones = [];

  /// IDs ya procesados — evita tratar notificaciones existentes como nuevas.
  final Set<String> _idsVistos = {};

  Timer? _pollingTimer;
  bool _modoVigilante = false;
  String _telefonoVigilante = '';
  int _paginaActual = 1;
  String? _filtroEstadoActual;
  PaginacionModel _paginacionActual = PaginacionModel.vacia;

  NotificationBloc({NotificationRepository? repository})
      : _repository = repository ?? NotificationRepository(),
        super(NotificationInitial()) {
    // ── Handlers que ya existían ──────────────────────────────────────────
    on<CargarNotificaciones>(_onCargarNotificaciones);
    on<NotificacionRecibida>(_onNotificacionRecibida);
    on<MarcarComoLeida>(_onMarcarComoLeida);
    on<LimpiarNotificaciones>(_onLimpiar);

    // ── Handlers nuevos ───────────────────────────────────────────────────
    on<IniciarPollingNotificaciones>(_onIniciarPolling);
    on<IniciarPollingVigilante>(_onIniciarPollingVigilante);
    on<DetenerPollingNotificaciones>(_onDetenerPolling);
    on<_TickPolling>(_onTick);
    on<MarcarNotificacionLeida>(_onMarcarNotificacionLeida);
    on<MarcarTodasLeidas>(_onMarcarTodasLeidas);
    on<AutorizarExtensionQr>(_onAutorizarExtension);
  }

  // =========================================================================
  // Handlers que ya existían — lógica original preservada
  // =========================================================================

  Future<void> _onCargarNotificaciones(
    CargarNotificaciones event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());

    try {
      _paginaActual = event.pagina;
      _filtroEstadoActual = event.estado;

      final resultado = _modoVigilante
          ? await _repository.obtenerNotificacionesVigilante(
              telefono: _telefonoVigilante,
              pagina: event.pagina,
              estado: event.estado,
            )
          : await _repository.obtenerNotificaciones(
              pagina: event.pagina,
              estado: event.estado,
            );

      _paginacionActual = resultado.paginacion;

      _notificaciones
        ..clear()
        ..addAll(resultado.items);

      for (final n in resultado.items) {
        _idsVistos.add(n.id);
      }

      AppLogger.info(
        _modulo,
        'Notificaciones cargadas: ${_notificaciones.length}',
      );

      emit(NotificacionesLoaded(
        notificaciones: List.from(_notificaciones),
        noLeidas: _notificaciones.where((n) => !n.leida).length,
        paginacion: _paginacionActual,
      ));
    } on NotFoundException catch (_) {
      _detenerPollingPor404();
      emit(const NotificationError(
        mensaje:
            'El servidor no tiene la ruta /notificaciones (404). '
            'Levante gestion-accesos, actualice la URL de ngrok en '
            'app_config.dart y vuelva a iniciar sesión.',
      ));
    } on AppException catch (e) {
      emit(NotificationError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error al cargar notificaciones: $e');
      emit(const NotificationError(
        mensaje:
            'No fue posible obtener las notificaciones. Intente nuevamente',
      ));
    }
  }

  void _onNotificacionRecibida(
    NotificacionRecibida event,
    Emitter<NotificationState> emit,
  ) {
    AppLogger.info(
      _modulo,
      'Nueva notificación recibida localmente: ${event.notificacion.tipo}',
    );

    _notificaciones.insert(0, event.notificacion);
    _idsVistos.add(event.notificacion.id);

    emit(NotificacionesLoaded(
      notificaciones: List.from(_notificaciones),
      noLeidas: _notificaciones.where((n) => !n.leida).length,
      paginacion: _paginacionActual,
    ));
  }

  void _onMarcarComoLeida(
    MarcarComoLeida event,
    Emitter<NotificationState> emit,
  ) {
    final index = _notificaciones.indexWhere(
      (n) => n.id == event.idNotificacion,
    );

    if (index != -1) {
      _notificaciones[index] = _notificaciones[index].copyWith(leida: true);

      emit(NotificacionesLoaded(
        notificaciones: List.from(_notificaciones),
        noLeidas: _notificaciones.where((n) => !n.leida).length,
        paginacion: _paginacionActual,
      ));
    }
  }

  void _onLimpiar(
    LimpiarNotificaciones event,
    Emitter<NotificationState> emit,
  ) {
    _notificaciones.clear();
    _idsVistos.clear();
    _pollingTimer?.cancel();
    _modoVigilante = false;
    _telefonoVigilante = '';
    _paginaActual = 1;
    _filtroEstadoActual = null;
    _paginacionActual = PaginacionModel.vacia;
    emit(NotificationInitial());
  }

  // =========================================================================
  // Handlers nuevos
  // =========================================================================

  Future<void> _onIniciarPolling(
    IniciarPollingNotificaciones event,
    Emitter<NotificationState> emit,
  ) async {
    _pollingTimer?.cancel();
    _modoVigilante = false;
    _telefonoVigilante = '';

    await _fetchYClasificar(emit);

    _pollingTimer = Timer.periodic(event.intervalo, (_) {
      if (!isClosed) add(_TickPolling());
    });

    AppLogger.info(_modulo,
        'Polling empleado iniciado cada ${event.intervalo.inSeconds}s');
  }

  Future<void> _onIniciarPollingVigilante(
    IniciarPollingVigilante event,
    Emitter<NotificationState> emit,
  ) async {
    if (event.telefono.isEmpty) {
      AppLogger.warning(_modulo, 'Polling vigilante omitido — teléfono vacío');
      return;
    }

    _pollingTimer?.cancel();
    _modoVigilante = true;
    _telefonoVigilante = event.telefono;

    await _fetchYClasificar(emit);

    _pollingTimer = Timer.periodic(event.intervalo, (_) {
      if (!isClosed) add(_TickPolling());
    });

    AppLogger.info(
      _modulo,
      'Polling vigilante iniciado cada ${event.intervalo.inSeconds}s',
    );
  }

  Future<void> _onDetenerPolling(
    DetenerPollingNotificaciones event,
    Emitter<NotificationState> emit,
  ) async {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _modoVigilante = false;
    _telefonoVigilante = '';
    AppLogger.info(_modulo, 'Polling detenido');
  }

  Future<void> _onTick(
    _TickPolling event,
    Emitter<NotificationState> emit,
  ) async {
    await _fetchYClasificar(emit);
  }

  Future<void> _onMarcarNotificacionLeida(
    MarcarNotificacionLeida event,
    Emitter<NotificationState> emit,
  ) async {
    // Actualizar local de inmediato para respuesta rápida en UI
    final index = _notificaciones.indexWhere(
      (n) => n.id == event.idNotificacion,
    );
    if (index != -1) {
      _notificaciones[index] = _notificaciones[index].copyWith(leida: true);
    }
    _emitirListaActual(emit);

    // Persistir en backend en silencio
    try {
      if (_modoVigilante) {
        await _repository.marcarLeidaVigilante(
          idNotificacion: event.idNotificacion,
          telefono: _telefonoVigilante,
        );
      } else {
        await _repository.marcarLeida(event.idNotificacion);
      }
    } catch (e) {
      AppLogger.error(_modulo, 'Error al marcar leída en backend: $e');
    }
  }

  Future<void> _onMarcarTodasLeidas(
    MarcarTodasLeidas event,
    Emitter<NotificationState> emit,
  ) async {
    for (int i = 0; i < _notificaciones.length; i++) {
      _notificaciones[i] = _notificaciones[i].copyWith(leida: true);
    }
    _emitirListaActual(emit);

    try {
      await _repository.marcarTodasLeidas();
    } catch (e) {
      AppLogger.error(_modulo, 'Error al marcar todas en backend: $e');
    }
  }

  Future<void> _onAutorizarExtension(
    AutorizarExtensionQr event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.extenderQr(event.idSolicitud);
      AppLogger.info(
          _modulo, 'QR extendido — id_solicitud: ${event.idSolicitud}');
      emit(const ExtensionQrResultado(
        exito: true,
        mensaje:
            'Tiempo extendido. El vigilante ya puede registrar el ingreso.',
      ));
    } catch (e) {
      AppLogger.error(_modulo, 'Error al extender QR: $e');
      emit(const ExtensionQrResultado(
        exito: false,
        mensaje: 'No fue posible extender el tiempo. Intenta nuevamente.',
      ));
    }
    _emitirListaActual(emit);
  }

  // =========================================================================
  // Helpers privados
  // =========================================================================

  /// Descarga notificaciones y emite [NuevaNotificacionRecibida] si hay
  /// alguna accionable nueva, o [NotificacionesLoaded] en caso contrario.
  /// Nunca emite [NotificationLoading] para no interrumpir la UI.
  Future<void> _fetchYClasificar(Emitter<NotificationState> emit) async {
    try {
      final resultado = _modoVigilante
          ? await _repository.obtenerNotificacionesVigilante(
              telefono: _telefonoVigilante,
              pagina: _paginaActual,
              estado: _filtroEstadoActual,
            )
          : await _repository.obtenerNotificaciones(
              pagina: _paginaActual,
              estado: _filtroEstadoActual,
            );

      _paginacionActual = resultado.paginacion;

      final nuevasAccionables = resultado.items.where((n) {
        final esNueva = !_idsVistos.contains(n.id);
        return esNueva && _esAccionable(n.tipo);
      }).toList();

      for (final n in resultado.items) {
        _idsVistos.add(n.id);
      }

      _notificaciones
        ..clear()
        ..addAll(resultado.items);

      final noLeidas = resultado.items.where((n) => !n.leida).length;

      if (nuevasAccionables.isNotEmpty) {
        AppLogger.info(
            _modulo, 'Accionable detectada: ${nuevasAccionables.first.tipo}');
        emit(NuevaNotificacionRecibida(
          notificacion: nuevasAccionables.first,
          todasLasNotificaciones: List.from(_notificaciones),
          noLeidas: noLeidas,
          paginacion: _paginacionActual,
        ));
      } else {
        emit(NotificacionesLoaded(
          notificaciones: List.from(_notificaciones),
          noLeidas: noLeidas,
          paginacion: _paginacionActual,
        ));
      }
    } on NotFoundException catch (_) {
      _detenerPollingPor404();
    } catch (e) {
      AppLogger.error(_modulo, 'Error en polling (silenciado): $e');
      // Silenciamos para no reemplazar la UI con un estado de error en segundo plano
    }
  }

  void _detenerPollingPor404() {
    if (_pollingTimer == null) return;

    _pollingTimer?.cancel();
    _pollingTimer = null;

    AppLogger.error(
      _modulo,
      'Polling detenido — GET /notificaciones devolvió 404. '
      'Confirme que gestion-accesos está corriendo con routes/api.php actualizado '
      'y que baseUrlProd en app_config.dart apunta al túnel ngrok vigente.',
    );
  }

  bool _esAccionable(TipoNotificacion tipo) {
    if (_modoVigilante) {
      return tipo == TipoNotificacion.qrExtendido;
    }

    return tipo == TipoNotificacion.visitanteIngreso ||
        tipo == TipoNotificacion.solicitudExtension ||
        tipo == TipoNotificacion.qrExpiradoTolerancia;
  }

  void _emitirListaActual(Emitter<NotificationState> emit) {
    emit(NotificacionesLoaded(
      notificaciones: List.from(_notificaciones),
      noLeidas: _notificaciones.where((n) => !n.leida).length,
      paginacion: _paginacionActual,
    ));
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
