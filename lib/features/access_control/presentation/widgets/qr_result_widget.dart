// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : qr_result_widget.dart
// Módulo    : features/access_control/presentation/extension_dialog.dart
// Autor     : Omega Company
// Fecha     : 2026-05-29
// Versión   : 2.0.0
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/access_datasource.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/config/app_config.dart';

import '../../bloc/access_control_bloc.dart';
import '../../data/access_model.dart';

class QrResultWidget extends StatelessWidget {
  final QrScanResultModel resultado;
  final VoidCallback? onExtenderTiempo;
  final VoidCallback? onNuevoEscaneo;

  const QrResultWidget({
    super.key,
    required this.resultado,
    this.onExtenderTiempo,
    this.onNuevoEscaneo,
  });

  // ── Helpers de formato ────────────────────────────────────────────────────

  String _formatHora(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h  = dt.hour.toString().padLeft(2, '0');
      final m  = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '--:--';
    }
  }

  String _formatFechaHora(String iso) {
    try {
      final dt  = DateTime.parse(iso).toLocal();
      final dia = dt.day.toString().padLeft(2, '0');
      final mes = dt.month.toString().padLeft(2, '0');
      final h   = dt.hour.toString().padLeft(2, '0');
      final m   = dt.minute.toString().padLeft(2, '0');
      return '$dia/$mes/${dt.year}  $h:$m';
    } catch (_) {
      return '—';
    }
  }

  // Determina el motivo de rechazo de forma clara y específica
  String _motivoLegible() {
    final motivo = resultado.motivoRechazo ?? '';
    if (motivo.contains('no encontrado'))  return 'El código QR no existe en el sistema.';
    if (motivo.contains('cancelado'))      return 'Este QR fue cancelado por el solicitante o el sistema.';
    if (motivo.contains('aún no es válido')) {
      final desde = _formatFechaHora(resultado.vigenciaInicio);
      return 'La visita no puede ingresar.\nVálido : $desde hrs';
    }
    if (motivo.contains('expirado') || motivo.contains('pasó')) {
      final hasta = _formatFechaHora(resultado.vigenciaFin);
      return 'El tiempo de visita expiró.\nVenció el: $hasta';
    }
    return motivo.isNotEmpty ? motivo : 'Acceso no autorizado.';
  }

  @override
  Widget build(BuildContext context) {
    final bool concedido  = resultado.accesoConcedido;
    final bool esEntrada  = resultado.accionDisponible == 'entrada';
    final Color colorPrin = concedido ? AppColors.successGreen : AppColors.actionRed;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorPrin.withOpacity(0.07),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: colorPrin, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── Icono + Estado ───────────────────────────────────────────────
          Icon(
            concedido ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 64,
            color: colorPrin,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            concedido ? AppStrings.accesoPermitido : AppStrings.accesoDenegado,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colorPrin,
            ),
          ),

          // ── Acción que se ejecutó ────────────────────────────────────────
          if (concedido) ...[
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: esEntrada ? AppColors.headingSky : AppColors.subtleWarm,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Text(
                  esEntrada ? 'ENTRADA REGISTRADA' : '✔ SALIDA REGISTRADA',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepNavy,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),

          // ── Datos del visitante ──────────────────────────────────────────
          _seccion(
            icono: Icons.person_rounded,
            titulo: 'Visitante',
            contenido: resultado.nombreVisitante.isNotEmpty
                ? resultado.nombreVisitante
                : '—',
          ),

          if (resultado.motivoVisita.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _seccion(
              icono: Icons.description_rounded,
              titulo: 'Motivo de visita',
              contenido: resultado.motivoVisita,
            ),
          ],

          if (resultado.lugarEncuentro.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _seccion(
              icono: Icons.location_on_rounded,
              titulo: 'Área de destino',
              contenido: resultado.lugarEncuentro,
            ),
          ],

          if (resultado.nombreSolicitante.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _seccion(
              icono: Icons.badge_rounded,
              titulo: 'Solicitante / Anfitrión',
              contenido: resultado.departamentoSolicitante.isNotEmpty
                  ? '${resultado.nombreSolicitante}\n${resultado.departamentoSolicitante}'
                  : resultado.nombreSolicitante,
            ),
          ],

          // ── Vigencia y tolerancia ────────────────────────────────────────
          if (resultado.vigenciaInicio.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _seccion(
              icono: Icons.schedule_rounded,
              titulo: 'Ventana de acceso',
              contenido: _buildVentanaAcceso(),
            ),
          ],

          // ── Motivo de rechazo claro ──────────────────────────────────────
          // ── Motivo de rechazo claro ──────────────────────────────────────────────
          if (!concedido) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.actionRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                border: Border.all(color: AppColors.actionRed.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.actionRed, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _motivoLegible(),
                      style: const TextStyle(
                        color: AppColors.actionRed,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Botón de solicitar extensión — solo si el QR existe y expiró
            if (resultado.idQr > 0 &&
                (resultado.motivoRechazo?.contains('expirado') == true ||
                    resultado.motivoRechazo?.contains('pasó') == true)) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _solicitarExtension(context),
                  icon: const Icon(
                    Icons.timer_outlined,
                    color: AppColors.primaryCoral,
                  ),
                  label: const Text(
                    'Notificar al anfitrión para extender tiempo',
                    style: TextStyle(color: AppColors.primaryCoral),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryCoral),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    ),
                  ),
                ),
              ),
            ],
          ],

          const SizedBox(height: AppSpacing.xl),

          // ── Botón de acción (solo si acceso concedido) ───────────────────
          // NOTA: El escaneo ya registró la entrada/salida en el backend.
          // Estos botones ya no son necesarios en el flujo de un solo paso.
          // Se conservan ocultos por si se requiere flujo de dos pasos en el futuro.

          // ── Botón nuevo escaneo ──────────────────────────────────────────
          if (onNuevoEscaneo != null)
            TextButton.icon(
              onPressed: onNuevoEscaneo,
              icon: const Icon(Icons.qr_code_scanner_rounded,
                  color: AppColors.neutralGrey),
              label: const Text(
                'Nuevo escaneo',
                style: TextStyle(color: AppColors.neutralGrey),
              ),
            ),
        ],
      ),
    );
  }
  Future<void> _solicitarExtension(BuildContext context) async {
    try {
      final datasource = AccessDatasource();
      await datasource.solicitarExtension(idQr: resultado.idQr);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificación enviada al anfitrión.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo enviar la notificación. Intenta de nuevo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  // ── Ventana de acceso con tolerancia ─────────────────────────────────────
  String _buildVentanaAcceso() {
    try {
      final inicio = DateTime.parse(resultado.vigenciaInicio).toLocal();
      final fin    = DateTime.parse(resultado.vigenciaFin).toLocal();

      final horaInicio = _formatHora(resultado.vigenciaInicio);
      final horaFin    = _formatHora(resultado.vigenciaFin);

      String detalle = '$horaInicio — $horaFin';

      if (resultado.toleranciaAntes > 0 || resultado.toleranciaDespues > 0) {
        detalle += '\n(Tolerancia: ';
        if (resultado.toleranciaAntes > 0) {
          detalle += '${resultado.toleranciaAntes} min antes';
        }
        if (resultado.toleranciaAntes > 0 && resultado.toleranciaDespues > 0) {
          detalle += ', ';
        }
        if (resultado.toleranciaDespues > 0) {
          detalle += '${resultado.toleranciaDespues} min después';
        }
        detalle += ')';
      }

      return detalle;
    } catch (_) {
      return '—';
    }
  }

  // ── Widget de sección de información ─────────────────────────────────────
  Widget _seccion({
    required IconData icono,
    required String titulo,
    required String contenido,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 18, color: AppColors.steelBlue),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.neutralGrey,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                contenido,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.deepNavy,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}