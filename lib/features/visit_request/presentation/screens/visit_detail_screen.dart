// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : visit_detail_screen.dart
// Módulo    : features/visit_request/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-27
// Versión   : 1.0.0
// Descripción: Pantalla de detalle de solicitud de visita — RF-017
// =============================================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../data/visit_request_model.dart';
import '../../data/visit_request_repository.dart';

class VisitDetailScreen extends StatefulWidget {
  final int idSolicitud;

  const VisitDetailScreen({
    super.key,
    required this.idSolicitud,
  });

  @override
  State<VisitDetailScreen> createState() => _VisitDetailScreenState();
}

class _VisitDetailScreenState extends State<VisitDetailScreen> {
  final VisitRequestRepository _repository = VisitRequestRepository();

  late Future<VisitRequestModel> _futureSolicitud;

  @override
  void initState() {
    super.initState();
    _futureSolicitud = _repository.obtenerDetalle(widget.idSolicitud);
  }

  Future<void> _recargar() async {
    setState(() {
      _futureSolicitud = _repository.obtenerDetalle(widget.idSolicitud);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseSurface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryCoral,
        title: const Text(
          'Detalle de solicitud',
          style: TextStyle(color: AppColors.baseSurface),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.baseSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<VisitRequestModel>(
        future: _futureSolicitud,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(
              mensaje: 'Cargando detalle...',
            );
          }

          if (snapshot.hasError) {
            return ErrorMessageWidget(
              mensaje: 'No fue posible cargar el detalle de la solicitud.',
              onReintentar: _recargar,
            );
          }

          final solicitud = snapshot.data;

          if (solicitud == null) {
            return ErrorMessageWidget(
              mensaje: 'No se encontró la solicitud.',
              onReintentar: _recargar,
            );
          }

          return RefreshIndicator(
            onRefresh: _recargar,
            color: AppColors.primaryCoral,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.paddingPantalla),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _EncabezadoSolicitud(solicitud: solicitud),
                  const SizedBox(height: AppSpacing.md),

                  _SeccionDetalle(
                    titulo: 'Información de la visita',
                    icono: Icons.assignment_outlined,
                    children: [
                      _FilaDetalle(
                        icono: Icons.confirmation_number_outlined,
                        titulo: 'Folio',
                        valor: solicitud.folio ?? 'Sin folio',
                      ),
                      _FilaDetalle(
                        icono: Icons.category_outlined,
                        titulo: 'Tipo de visita',
                        valor: solicitud.tipoVisita,
                      ),
                      _FilaDetalle(
                        icono: Icons.location_on_outlined,
                        titulo: 'Lugar de encuentro',
                        valor: solicitud.lugarDestino,
                      ),
                      _FilaDetalle(
                        icono: Icons.calendar_today_outlined,
                        titulo: 'Fecha y hora',
                        valor: _formatearFecha(solicitud.fechaVisita),
                      ),
                      _FilaDetalle(
                        icono: Icons.access_time_outlined,
                        titulo: 'Tolerancia',
                        valor:
                        '${solicitud.toleranciaAntesMinutos} min antes / ${solicitud.toleranciaDespuesMinutos} min después',
                      ),
                      _FilaDetalle(
                        icono: Icons.notes_outlined,
                        titulo: 'Motivo',
                        valor: solicitud.motivoVisita,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  _SeccionDetalle(
                    titulo: solicitud.esGrupal
                        ? 'Visitantes del grupo'
                        : 'Visitante',
                    icono: Icons.people_alt_outlined,
                    children: solicitud.visitantes.isEmpty
                        ? [
                      const _FilaDetalle(
                        icono: Icons.person_off_outlined,
                        titulo: 'Visitantes',
                        valor: 'No hay visitantes registrados',
                      ),
                    ]
                        : solicitud.visitantes
                        .asMap()
                        .entries
                        .map(
                          (entry) => _VisitanteItem(
                        indice: entry.key + 1,
                        visitante: entry.value,
                      ),
                    )
                        .toList(),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  if (solicitud.estado.toLowerCase() == 'autorizada')
                    _AvisoQrAutorizado(),

                  if (solicitud.estado.toLowerCase() == 'pendiente')
                    _AvisoPendiente(),

                  if (solicitud.estado.toLowerCase() == 'rechazada')
                    _AvisoRechazada(),

                  if (solicitud.estado.toLowerCase() == 'cancelada')
                    _AvisoCancelada(),
                ],
              ),
            ),
          );
        },
      ),
    );
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

class _EncabezadoSolicitud extends StatelessWidget {
  final VisitRequestModel solicitud;

  const _EncabezadoSolicitud({
    required this.solicitud,
  });

  @override
  Widget build(BuildContext context) {
    final colorEstado = _colorEstado(solicitud.estado);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: colorEstado.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colorEstado.withOpacity(0.15),
                child: Icon(
                  _iconoEstado(solicitud.estado),
                  color: colorEstado,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      solicitud.folio ?? 'Solicitud de visita',
                      style: const TextStyle(
                        color: AppColors.deepNavy,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      solicitud.esGrupal ? 'Visita grupal' : 'Visita individual',
                      style: const TextStyle(
                        color: AppColors.neutralGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: colorEstado.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            child: Text(
              solicitud.estado,
              style: TextStyle(
                color: colorEstado,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'autorizada':
        return AppColors.successGreen;
      case 'pendiente':
        return AppColors.warningOrange;
      case 'rechazada':
      case 'cancelada':
        return AppColors.actionRed;
      default:
        return AppColors.headingSky;
    }
  }

  IconData _iconoEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'autorizada':
        return Icons.check_circle_outline_rounded;
      case 'pendiente':
        return Icons.pending_actions_rounded;
      case 'rechazada':
        return Icons.cancel_outlined;
      case 'cancelada':
        return Icons.block_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }
}

class _SeccionDetalle extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final List<Widget> children;

  const _SeccionDetalle({
    required this.titulo,
    required this.icono,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.baseSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.surface),
        boxShadow: [
          BoxShadow(
            color: AppColors.surface,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icono,
                color: AppColors.primaryCoral,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                titulo,
                style: const TextStyle(
                  color: AppColors.deepNavy,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _FilaDetalle extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _FilaDetalle({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icono,
            size: 20,
            color: AppColors.steelBlue,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: AppColors.neutralGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor.trim().isEmpty ? 'Sin información' : valor,
                  style: const TextStyle(
                    color: AppColors.headingDark,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitanteItem extends StatelessWidget {
  final int indice;
  final VisitanteModel visitante;

  const _VisitanteItem({
    required this.indice,
    required this.visitante,
  });

  @override
  Widget build(BuildContext context) {
    final nombreCompleto =
    '${visitante.nombre} ${visitante.apellidos}'.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryCoral.withOpacity(0.15),
            child: Text(
              indice.toString(),
              style: const TextStyle(
                color: AppColors.primaryCoral,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombreCompleto.isEmpty ? 'Visitante $indice' : nombreCompleto,
                  style: const TextStyle(
                    color: AppColors.deepNavy,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  visitante.correo,
                  style: const TextStyle(
                    color: AppColors.neutralGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvisoQrAutorizado extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _AvisoEstado(
      icono: Icons.qr_code_2_rounded,
      titulo: 'Solicitud autorizada',
      mensaje:
      'La visita fue autorizada. El código QR se genera desde el backend y podrá consultarse o enviarse según la configuración del sistema.',
      color: AppColors.successGreen,
    );
  }
}

class _AvisoPendiente extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _AvisoEstado(
      icono: Icons.pending_actions_rounded,
      titulo: 'Solicitud pendiente',
      mensaje:
      'La solicitud aún está esperando revisión por parte del autorizador.',
      color: AppColors.warningOrange,
    );
  }
}

class _AvisoRechazada extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _AvisoEstado(
      icono: Icons.cancel_outlined,
      titulo: 'Solicitud rechazada',
      mensaje:
      'La solicitud fue rechazada. Revisa los datos o contacta al área correspondiente.',
      color: AppColors.actionRed,
    );
  }
}

class _AvisoCancelada extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _AvisoEstado(
      icono: Icons.block_outlined,
      titulo: 'Solicitud cancelada',
      mensaje:
      'La solicitud fue cancelada y ya no se encuentra activa para acceso.',
      color: AppColors.actionRed,
    );
  }
}

class _AvisoEstado extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String mensaje;
  final Color color;

  const _AvisoEstado({
    required this.icono,
    required this.titulo,
    required this.mensaje,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icono,
            color: color,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  mensaje,
                  style: const TextStyle(
                    color: AppColors.headingDark,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}