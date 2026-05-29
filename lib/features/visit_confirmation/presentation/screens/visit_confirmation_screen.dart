// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : visit_confirmation_screen.dart
// Módulo    : features/visit_confirmation/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-29
// Versión   : 2.0.0
// Descripción: Pantalla de confirmación de visita con notificaciones en tiempo
//              real — RF-026, RF-051, RF-052, RF-023
//
// Cambios v2:
//  - Escucha NotificationBloc para refrescarse automáticamente.
//  - Resalta con borde coral la visita que generó la última notificación.
//  - Muestra diálogo de decisión cuando llega solicitud de extensión.
//  - Notificaciones locales al recibir visitante_ingreso y solicitud_extension.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import 'package:sistema_accesos_app/core/widgets/error_widget.dart';
import '../../../../core/utils/paginacion_local.dart';
import '../../../../core/widgets/safe_scaffold_body_widget.dart';
import '../../../../core/widgets/empty_list_state_widget.dart';
import '../../../../core/widgets/list_stats_header_widget.dart';
import '../../../../core/widgets/paginated_list_column_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/primary_button_widget.dart';
import '../../bloc/visit_confirmation_bloc.dart';
import '../../data/confirmation_model.dart';
import '../../data/confirmation_repository.dart';
import '../../../notifications/bloc/notification_bloc.dart';
import '../../../notifications/data/notification_model.dart';
import '../../../notifications/data/notification_service.dart';
import 'package:sistema_accesos_app/features/visit_confirmation/presentation/screens/widgets/extension_dialog.dart';

// =============================================================================
// Pantalla raíz — provee ambos Blocs
// =============================================================================

class VisitConfirmationScreen extends StatelessWidget {
  const VisitConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VisitConfirmationBloc(
        repository: ConfirmationRepository(),
      )..add(CargarVisitasActivas()),
      child: const _VisitConfirmationView(),
    );
  }
}

// =============================================================================
// Vista principal
// =============================================================================

class _VisitConfirmationView extends StatefulWidget {
  const _VisitConfirmationView();

  @override
  State<_VisitConfirmationView> createState() => _VisitConfirmationViewState();
}

class _VisitConfirmationViewState extends State<_VisitConfirmationView> {
  /// Folio de la visita que generó la última notificación (para resaltado)
  String? _folioResaltado;
  int _paginaActual = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseSurface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryCoral,
        title: const Text(
          'Visitas activas',
          style: TextStyle(color: AppColors.baseSurface),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.baseSurface),
          onPressed: () => Navigator.pop(context),
        ),
        // Badge de no leídas
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              int noLeidas = 0;
              if (state is NotificacionesLoaded) noLeidas = state.noLeidas;
              if (state is NuevaNotificacionRecibida) noLeidas = state.noLeidas;

              if (noLeidas == 0) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.notifications_rounded,
                        color: AppColors.baseSurface),
                    Positioned(
                      top: 6,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.actionRed,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$noLeidas',
                          style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      // ── Listeners combinados ──────────────────────────────────────────────
      body: SafeScaffoldBody(
        child: MultiBlocListener(
        listeners: [
          // ── VisitConfirmationBloc ─────────────────────────────────────────
          BlocListener<VisitConfirmationBloc, VisitConfirmationState>(
            listener: (context, state) {
              if (state is ConfirmationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.mensaje),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
                context
                    .read<VisitConfirmationBloc>()
                    .add(CargarVisitasActivas());
              } else if (state is VisitConfirmationError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.mensaje),
                    backgroundColor: AppColors.actionRed,
                  ),
                );
              }
            },
          ),

          // ── NotificationBloc ──────────────────────────────────────────────
          BlocListener<NotificationBloc, NotificationState>(
            listener: (context, state) async {
              if (state is! NuevaNotificacionRecibida) return;

              final notif = state.notificacion;

              // 1. Visitante ingresó al campus
              if (notif.tipo == TipoNotificacion.visitanteIngreso) {
                // Mostrar notificación local (cabecera)
                await NotificationService.instancia.notificarIngresoVisitante(
                  nombreVisitante: notif.nombreVisitante ?? 'Visitante',
                  area: '',
                );

                // Resaltar la visita en la lista
                setState(() {
                  _folioResaltado = notif.folio;
                });

                // Refrescar la lista para mostrar al visitante como activo
                if (context.mounted) {
                  context
                      .read<VisitConfirmationBloc>()
                      .add(CargarVisitasActivas());
                }

                // Marcar como leída en el backend
                if (notif.id.isNotEmpty) {
                  context
                      .read<NotificationBloc>()
                      .add(MarcarNotificacionLeida(
                      idNotificacion: notif.id));
                }
              }

              // 2. Solicitud de extensión (visitante llegó tarde)
              else if (notif.tipo == TipoNotificacion.solicitudExtension ||
                  notif.tipo == TipoNotificacion.qrExpiradoTolerancia) {
                // Mostrar notificación local
                await NotificationService.instancia
                    .notificarSolicitudExtension(
                  nombreVisitante: notif.nombreVisitante ?? 'Visitante',
                  folio: notif.folio ?? '—',
                );

                // Mostrar diálogo de decisión
                if (context.mounted) {
                  await mostrarDialogoExtension(
                    context: context,
                    notificacion: notif,
                    notificationBloc:
                    context.read<NotificationBloc>(),
                  );
                }

                // Marcar como leída
                if (notif.id.isNotEmpty && context.mounted) {
                  context
                      .read<NotificationBloc>()
                      .add(MarcarNotificacionLeida(
                      idNotificacion: notif.id));
                }
              }
            },
          ),
        ],

        // ── Builder de la lista ───────────────────────────────────────────
        child: BlocBuilder<VisitConfirmationBloc, VisitConfirmationState>(
          builder: (context, state) {
            if (state is VisitConfirmationLoading) {
              return const LoadingWidget(
                  mensaje: 'Cargando visitas activas...');
            }

            if (state is VisitConfirmationError) {
              return ErrorMessageWidget(
                mensaje: state.mensaje,
                onReintentar: () {
                  context
                      .read<VisitConfirmationBloc>()
                      .add(CargarVisitasActivas());
                },
              );
            }

            if (state is VisitasActivasLoaded) {
              final paginado = PaginacionLocal.paginar(
                state.visitas,
                pagina: _paginaActual,
              );

              if (state.visitas.isEmpty) {
                return EmptyListStateWidget(
                  icono: Icons.people_outline_rounded,
                  titulo: 'No hay visitas activas en este momento',
                  subtitulo:
                      'Cuando un visitante ingrese al campus aparecerá aquí.',
                  accionTexto: 'Actualizar',
                  onAccion: () => context
                      .read<VisitConfirmationBloc>()
                      .add(CargarVisitasActivas()),
                );
              }

              return Column(
                children: [
                  ListStatsHeaderWidget(
                    titulo: 'Visitas en curso',
                    paginacion: paginado.paginacion,
                    icono: Icons.groups_rounded,
                  ),
                  Expanded(
                    child: PaginatedListColumnWidget(
                      paginacion: paginado.paginacion,
                      onPaginaSeleccionada: (pagina) {
                        setState(() => _paginaActual = pagina);
                      },
                      child: RefreshIndicator(
                        color: AppColors.primaryCoral,
                        onRefresh: () async {
                          setState(() => _paginaActual = 1);
                          context
                              .read<VisitConfirmationBloc>()
                              .add(CargarVisitasActivas());
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: paginado.items.length,
                          itemBuilder: (context, index) {
                            final visita = paginado.items[index];
                            final esResaltada =
                                visita.folio == _folioResaltado;

                            return _VisitaActivaCard(
                              visita: visita,
                              resaltada: esResaltada,
                              onAccionCompletada: () {
                                setState(() => _folioResaltado = null);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
        ),
      ),
    );
  }
}

// =============================================================================
// Card de visita activa con resaltado condicional
// =============================================================================

class _VisitaActivaCard extends StatelessWidget {
  final ConfirmationModel visita;
  final bool resaltada;
  final VoidCallback? onAccionCompletada;

  const _VisitaActivaCard({
    required this.visita,
    this.resaltada = false,
    this.onAccionCompletada,
  });

  @override
  Widget build(BuildContext context) {
    // El borde coral indica que esta visita generó la última notificación
    final colorBorde =
    resaltada ? AppColors.primaryCoral : AppColors.headingSky;
    final anchoBorde = resaltada ? 2.0 : 1.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: resaltada
            ? AppColors.primaryCoral.withValues(alpha: 0.05)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: colorBorde, width: anchoBorde),
        boxShadow: resaltada
            ? [
          BoxShadow(
            color: AppColors.primaryCoral.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera con nombre y chip de "recién llegó"
          Row(
            children: [
              Expanded(
                child: Text(
                  visita.nombreVisitante,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepNavy,
                  ),
                ),
              ),
              if (resaltada)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryCoral,
                    borderRadius:
                    BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: const Text(
                    '● Recién llegó',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Folio: ${visita.folio}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.neutralGrey,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Timeline
          _TimelineItem(
            icono: Icons.login_rounded,
            label: 'Llegada al campus',
            hora: visita.horaLlegadaCampus,
          ),
          _TimelineItem(
            icono: Icons.room_rounded,
            label: 'Llegada al área',
            hora: visita.horaLlegadaArea,
          ),
          _TimelineItem(
            icono: Icons.logout_rounded,
            label: 'Salida del área',
            hora: visita.horaSalidaArea,
          ),
          const SizedBox(height: AppSpacing.md),

          // Botones de acción
          if (visita.horaLlegadaArea == null) ...[
            PrimaryButtonWidget(
              texto: 'Confirmar llegada al área',
              icono: Icons.check_circle_outline_rounded,
              onPressed: () {
                context.read<VisitConfirmationBloc>().add(
                  ConfirmarLlegadaArea(
                      idSolicitud: visita.idSolicitud),
                );
                onAccionCompletada?.call();
              },
            ),
          ] else if (visita.horaSalidaArea == null) ...[
            SizedBox(
              height: AppSpacing.alturaBoton,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<VisitConfirmationBloc>().add(
                    ConfirmarSalidaArea(
                        idSolicitud: visita.idSolicitud),
                  );
                  onAccionCompletada?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.headingDark,
                  foregroundColor: AppColors.baseSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Registrar salida del área'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// Timeline item (sin cambios vs v1)
// =============================================================================

class _TimelineItem extends StatelessWidget {
  final IconData icono;
  final String label;
  final DateTime? hora;

  const _TimelineItem({
    required this.icono,
    required this.label,
    this.hora,
  });

  @override
  Widget build(BuildContext context) {
    final registrado = hora != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            icono,
            size: 18,
            color: registrado ? AppColors.successGreen : AppColors.surface,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color:
              registrado ? AppColors.onyxGrey : AppColors.neutralGrey,
            ),
          ),
          const Spacer(),
          Text(
            hora != null ? _formatearHora(hora!) : 'Pendiente',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: registrado
                  ? AppColors.successGreen
                  : AppColors.neutralGrey,
            ),
          ),
        ],
      ),
    );
  }

  String _formatearHora(DateTime hora) {
    return '${hora.hour}:${hora.minute.toString().padLeft(2, '0')}';
  }
}