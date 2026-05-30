// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : notifications_screen.dart
// Módulo    : features/notifications/presentation/screens
// Versión   : 1.2.0
// Descripción: Listado de notificaciones con filtros y paginación — RF-023
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/paginacion_model.dart';
import '../../../../core/widgets/safe_scaffold_body_widget.dart';
import '../../../../core/widgets/empty_list_state_widget.dart';
import '../../../../core/widgets/estado_filtro_bar_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/paginated_list_column_widget.dart';
import 'package:sistema_accesos_app/core/widgets/error_widget.dart';
import '../../bloc/notification_bloc.dart';
import '../../data/notification_model.dart';
import '../../../visit_confirmation/presentation/screens/visit_confirmation_screen.dart';
import '../../../visit_request/presentation/screens/visit_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _paginaActual = 1;
  String? _filtroEstado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  void _cargar({int? pagina}) {
    final paginaDestino = pagina ?? _paginaActual;
    setState(() => _paginaActual = paginaDestino);
    context.read<NotificationBloc>().add(
          CargarNotificaciones(
            pagina: paginaDestino,
            estado: _filtroEstado,
          ),
        );
  }

  void _onFiltroChanged(String? estado) {
    setState(() {
      _filtroEstado = estado;
      _paginaActual = 1;
    });
    context.read<NotificationBloc>().add(
          CargarNotificaciones(pagina: 1, estado: estado),
        );
  }

  @override
  Widget build(BuildContext context) {
    return _NotificationsView(
      filtroEstado: _filtroEstado,
      onFiltroChanged: _onFiltroChanged,
      onCargar: _cargar,
    );
  }
}

class _NotificationsView extends StatelessWidget {
  final String? filtroEstado;
  final ValueChanged<String?> onFiltroChanged;
  final void Function({int? pagina}) onCargar;

  const _NotificationsView({
    required this.filtroEstado,
    required this.onFiltroChanged,
    required this.onCargar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseSurface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryCoral,
        elevation: 0,
        title: const Text(
          'Notificaciones',
          style: TextStyle(color: AppColors.baseSurface),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.baseSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              final hayNoLeidas = _contarNoLeidas(state) > 0;
              if (!hayNoLeidas) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Marcar todas como leídas',
                icon: const Icon(Icons.done_all_rounded,
                    color: AppColors.baseSurface),
                onPressed: () {
                  context.read<NotificationBloc>().add(MarcarTodasLeidas());
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.baseSurface),
            onPressed: () => onCargar(),
          ),
        ],
      ),
      body: SafeScaffoldBody(
        child: Column(
        children: [
          EstadoFiltroBarWidget(
            filtroSeleccionado: filtroEstado,
            onFiltroChanged: onFiltroChanged,
          ),
          Expanded(
            child: BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoading) {
                  return const LoadingWidget(
                    mensaje: 'Cargando notificaciones...',
                  );
                }

                if (state is NotificationError) {
                  return ErrorMessageWidget(
                    mensaje: state.mensaje,
                    onReintentar: () => onCargar(),
                  );
                }

                final notificaciones = _extraerLista(state);
                final paginacion = _extraerPaginacion(state);

                if (notificaciones.isEmpty) {
                  return PaginatedListColumnWidget(
                    paginacion: paginacion,
                    onPaginaSeleccionada: (pagina) => onCargar(pagina: pagina),
                    child: RefreshIndicator(
                      color: AppColors.primaryCoral,
                      onRefresh: () async => onCargar(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          EmptyListStateWidget(
                            icono: Icons.notifications_off_outlined,
                            titulo: filtroEstado == null
                                ? 'No tienes notificaciones'
                                : 'No tienes notificaciones $filtroEstado',
                            subtitulo:
                                'Los avisos de visitas y solicitudes aparecerán aquí.',
                            accionTexto: 'Actualizar',
                            onAccion: () => onCargar(),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return PaginatedListColumnWidget(
                  paginacion: paginacion,
                  onPaginaSeleccionada: (pagina) => onCargar(pagina: pagina),
                  child: RefreshIndicator(
                    color: AppColors.primaryCoral,
                    onRefresh: () async => onCargar(),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: notificaciones.length,
                      itemBuilder: (context, index) {
                        final notificacion = notificaciones[index];
                        return _NotificationCard(
                          notificacion: notificacion,
                          onTap: () => _manejarToque(context, notificacion),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        ),
      ),
    );
  }

  List<NotificationModel> _extraerLista(NotificationState state) {
    if (state is NotificacionesLoaded) return state.notificaciones;
    if (state is NuevaNotificacionRecibida) return state.todasLasNotificaciones;
    return [];
  }

  PaginacionModel _extraerPaginacion(NotificationState state) {
    if (state is NotificacionesLoaded) return state.paginacion;
    if (state is NuevaNotificacionRecibida) return state.paginacion;
    return PaginacionModel.vacia;
  }

  int _contarNoLeidas(NotificationState state) {
    if (state is NotificacionesLoaded) return state.noLeidas;
    if (state is NuevaNotificacionRecibida) return state.noLeidas;
    return 0;
  }

  void _manejarToque(BuildContext context, NotificationModel notificacion) {
    if (!notificacion.leida) {
      context.read<NotificationBloc>().add(
            MarcarNotificacionLeida(idNotificacion: notificacion.id),
          );
    }

    switch (notificacion.tipo) {
      case TipoNotificacion.visitanteIngreso:
      case TipoNotificacion.visitanteSalida:
      case TipoNotificacion.solicitudExtension:
      case TipoNotificacion.qrExpiradoTolerancia:
      case TipoNotificacion.permanenciaExcedida:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<NotificationBloc>(),
              child: const VisitConfirmationScreen(),
            ),
          ),
        );
        break;
      case TipoNotificacion.solicitudAutorizada:
      case TipoNotificacion.solicitudRechazada:
      case TipoNotificacion.solicitudCancelada:
      case TipoNotificacion.qrExtendido:
        if (notificacion.idSolicitud != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VisitDetailScreen(
                idSolicitud: notificacion.idSolicitud!,
              ),
            ),
          );
        }
        break;
      case TipoNotificacion.visitanteLlegadaTarde:
      case TipoNotificacion.nuevaSolicitudPendiente:
        break;
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notificacion;
  final VoidCallback? onTap;

  const _NotificationCard({
    required this.notificacion,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorPorTipo(notificacion.tipo);
    final icono = _iconoPorTipo(notificacion.tipo);
    final esAccionable = notificacion.requiereAccion;

    return Material(
      color: notificacion.leida
          ? AppColors.baseSurface
          : color.withValues(alpha: 0.06),
      elevation: notificacion.leida ? 0 : 1,
      shadowColor: color.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            border: Border.all(
              color: notificacion.leida
                  ? AppColors.headingSky.withValues(alpha: 0.35)
                  : color.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icono, color: color, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notificacion.titulo,
                            style: TextStyle(
                              fontWeight: notificacion.leida
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: AppColors.deepNavy,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (esAccionable && !notificacion.leida)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusPill,
                              ),
                            ),
                            child: Text(
                              'Acción',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      notificacion.mensaje,
                      style: const TextStyle(
                        color: AppColors.neutralGrey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Text(
                          _formatearFecha(notificacion.fecha),
                          style: const TextStyle(
                            color: AppColors.steelBlue,
                            fontSize: 11,
                          ),
                        ),
                        if (esAccionable) ...[
                          const Spacer(),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: color,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (!notificacion.leida) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconoPorTipo(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.solicitudAutorizada:
        return Icons.check_circle_outline_rounded;
      case TipoNotificacion.solicitudRechazada:
      case TipoNotificacion.solicitudCancelada:
        return Icons.cancel_outlined;
      case TipoNotificacion.visitanteIngreso:
        return Icons.login_rounded;
      case TipoNotificacion.visitanteSalida:
        return Icons.logout_rounded;
      case TipoNotificacion.visitanteLlegadaTarde:
      case TipoNotificacion.qrExpiradoTolerancia:
        return Icons.access_time_rounded;
      case TipoNotificacion.permanenciaExcedida:
        return Icons.warning_amber_rounded;
      case TipoNotificacion.qrExtendido:
        return Icons.more_time_rounded;
      case TipoNotificacion.solicitudExtension:
        return Icons.timer_outlined;
      case TipoNotificacion.nuevaSolicitudPendiente:
        return Icons.notifications_rounded;
    }
  }

  Color _colorPorTipo(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.solicitudAutorizada:
      case TipoNotificacion.visitanteIngreso:
      case TipoNotificacion.visitanteSalida:
      case TipoNotificacion.qrExtendido:
        return AppColors.successGreen;
      case TipoNotificacion.solicitudRechazada:
      case TipoNotificacion.solicitudCancelada:
      case TipoNotificacion.visitanteLlegadaTarde:
      case TipoNotificacion.permanenciaExcedida:
        return AppColors.actionRed;
      case TipoNotificacion.qrExpiradoTolerancia:
      case TipoNotificacion.solicitudExtension:
        return AppColors.warningOrange;
      case TipoNotificacion.nuevaSolicitudPendiente:
        return AppColors.primaryCoral;
    }
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$anio $hora:$minuto';
  }
}
