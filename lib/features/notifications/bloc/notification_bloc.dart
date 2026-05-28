// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : notification_bloc.dart
// Módulo    : features/notifications/bloc
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Gestor de estado de notificaciones — RF-023
// =============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/notification_model.dart';
import '../data/notification_repository.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/errors/app_logger.dart';

// ── Eventos ──────────────────────────────────────────────────────────────────

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class CargarNotificaciones extends NotificationEvent {}

class NotificacionRecibida extends NotificationEvent {
  final NotificationModel notificacion;

  const NotificacionRecibida({
    required this.notificacion,
  });

  @override
  List<Object?> get props => [notificacion];
}

class MarcarComoLeida extends NotificationEvent {
  final String idNotificacion;

  const MarcarComoLeida({
    required this.idNotificacion,
  });

  @override
  List<Object?> get props => [idNotificacion];
}

class LimpiarNotificaciones extends NotificationEvent {}

// ── Estados ──────────────────────────────────────────────────────────────────

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificacionesLoaded extends NotificationState {
  final List<NotificationModel> notificaciones;
  final int noLeidas;

  const NotificacionesLoaded({
    required this.notificaciones,
    required this.noLeidas,
  });

  @override
  List<Object?> get props => [notificaciones, noLeidas];
}

class NotificationError extends NotificationState {
  final String mensaje;

  const NotificationError({
    required this.mensaje,
  });

  @override
  List<Object?> get props => [mensaje];
}

// ── Bloc ─────────────────────────────────────────────────────────────────────

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  static const String _modulo = 'NOTIFICATION_BLOC';

  final NotificationRepository _repository;
  final List<NotificationModel> _notificaciones = [];

  NotificationBloc({
    NotificationRepository? repository,
  })  : _repository = repository ?? NotificationRepository(),
        super(NotificationInitial()) {
    on<CargarNotificaciones>(_onCargarNotificaciones);
    on<NotificacionRecibida>(_onNotificacionRecibida);
    on<MarcarComoLeida>(_onMarcarComoLeida);
    on<LimpiarNotificaciones>(_onLimpiar);
  }

  Future<void> _onCargarNotificaciones(
      CargarNotificaciones event,
      Emitter<NotificationState> emit,
      ) async {
    emit(NotificationLoading());

    try {
      final notificaciones = await _repository.obtenerNotificaciones();

      _notificaciones
        ..clear()
        ..addAll(notificaciones);

      AppLogger.info(
        _modulo,
        'Notificaciones reales cargadas: ${_notificaciones.length}',
      );

      emit(NotificacionesLoaded(
        notificaciones: List.from(_notificaciones),
        noLeidas: _notificaciones.where((n) => !n.leida).length,
      ));
    } on AppException catch (e) {
      emit(NotificationError(mensaje: e.mensaje));
    } catch (e) {
      AppLogger.error(_modulo, 'Error al cargar notificaciones: $e');
      emit(const NotificationError(
        mensaje: 'No fue posible obtener las notificaciones. Intente nuevamente',
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

    emit(NotificacionesLoaded(
      notificaciones: List.from(_notificaciones),
      noLeidas: _notificaciones.where((n) => !n.leida).length,
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
      _notificaciones[index] = _notificaciones[index].copyWith(
        leida: true,
      );

      emit(NotificacionesLoaded(
        notificaciones: List.from(_notificaciones),
        noLeidas: _notificaciones.where((n) => !n.leida).length,
      ));
    }
  }

  void _onLimpiar(
      LimpiarNotificaciones event,
      Emitter<NotificationState> emit,
      ) {
    _notificaciones.clear();
    emit(NotificationInitial());
  }
}