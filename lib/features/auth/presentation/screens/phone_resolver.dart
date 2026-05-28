// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : phone_resolver.dart
// Módulo    : features/auth/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-28
// Versión   : 1.1.0
// =============================================================================

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sim_card_info/sim_card_info.dart';
import 'package:phone_number_hint/phone_number_hint.dart';

enum PhoneResolveStatus {
  success,
  empty,
  permissionDenied,
  cancelled,
  unsupported,
  error,
}

class PhoneResolveResult {
  final PhoneResolveStatus status;
  final String numero;

  const PhoneResolveResult({required this.status, this.numero = ''});
}

class PhoneResolver {
  static final _hint = PhoneNumberHint();

  // ── Entrada principal ──────────────────────────────────────────────────────
  static Future<PhoneResolveResult> resolver() async {
    final resultSIM = await _intentarConSIM();
    if (resultSIM.status == PhoneResolveStatus.success) return resultSIM;
    if (resultSIM.status == PhoneResolveStatus.permissionDenied) return resultSIM;
    return _intentarConHint();
  }

  // ── Método 1: leer número directo de la SIM ────────────────────────────────
  static Future<PhoneResolveResult> _intentarConSIM() async {
    try {
      final status = await Permission.phone.request();

      if (status.isPermanentlyDenied) {
        return const PhoneResolveResult(status: PhoneResolveStatus.permissionDenied);
      }
      if (!status.isGranted) {
        return const PhoneResolveResult(status: PhoneResolveStatus.empty);
      }

      final simInfo = SimCardInfo();
      final sims = await simInfo.getSimInfo();

      if (sims == null || sims.isEmpty) {
        return const PhoneResolveResult(status: PhoneResolveStatus.empty);
      }

      for (final sim in sims) {
        final numero = _normalizarTelefono(sim.number ?? '');
        if (numero.length == 10) {
          return PhoneResolveResult(
            status: PhoneResolveStatus.success,
            numero: numero,
          );
        }
      }

      return const PhoneResolveResult(status: PhoneResolveStatus.empty);
    } on PlatformException catch (e) {
      debugPrint('[PhoneResolver] sim_card_info PlatformException: ${e.message}');
      return const PhoneResolveResult(status: PhoneResolveStatus.error);
    } catch (e) {
      debugPrint('[PhoneResolver] sim_card_info error inesperado: $e');
      return const PhoneResolveResult(status: PhoneResolveStatus.error);
    }
  }

  // ── Método 2: Google Phone Number Hint ────────────────────────────────────
  static Future<PhoneResolveResult> _intentarConHint() async {
    try {
      final raw = await _hint.requestHint();

      if (raw == null || raw.trim().isEmpty) {
        return const PhoneResolveResult(status: PhoneResolveStatus.empty);
      }

      final numero = _normalizarTelefono(raw);

      if (numero.length != 10) {
        debugPrint('[PhoneResolver] Hint descartado (no es 10 dígitos): "$raw" → "$numero"');
        return const PhoneResolveResult(status: PhoneResolveStatus.empty);
      }

      return PhoneResolveResult(
        status: PhoneResolveStatus.success,
        numero: numero,
      );
    } on PlatformException catch (e) {
      debugPrint('[PhoneResolver] Hint cancelado por usuario: ${e.message}');
      return const PhoneResolveResult(status: PhoneResolveStatus.cancelled);
    } catch (e) {
      debugPrint('[PhoneResolver] Hint no disponible: $e');
      return const PhoneResolveResult(status: PhoneResolveStatus.unsupported);
    }
  }

  // ── Normalizar a exactamente 10 dígitos mexicanos ─────────────────────────
  // Casos que maneja:
  //   "+521234567890"  → "1234567890"
  //   "521234567890"   → "1234567890"
  //   "+52"            → ""  (descartado por longitud)
  //   "1234567890"     → "1234567890"
  //   "(123) 456-7890" → "1234567890"
  static String _normalizarTelefono(String raw) {
    if (raw.trim().isEmpty) return '';

    String digits = raw.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) return '';

    // Quitar prefijo +52 solo si quedan exactamente 12 dígitos
    if (digits.startsWith('52') && digits.length == 12) {
      digits = digits.substring(2);
    }

    // Si aún tiene más de 10, tomar los últimos 10
    if (digits.length > 10) {
      digits = digits.substring(digits.length - 10);
    }

    return digits;
  }
}