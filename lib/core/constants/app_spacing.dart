// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : app_spacing.dart
// Módulo    : core/constants
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Espaciado institucional — MPF-OMEGA-04 §7.1 Atomic Spacing
// =============================================================================

class AppSpacing {
  AppSpacing._();

  // ── Unidad base: 8dp ──────────────────────────────────────────────────────
  static const double xs  = 4.0;   // 0.5x — separación mínima
  static const double sm  = 8.0;   // 1x   — espaciado interno compacto
  static const double md  = 16.0;  // 2x   — espaciado estándar
  static const double lg  = 24.0;  // 3x   — padding de pantalla
  static const double xl  = 32.0;  // 4x   — separación entre secciones
  static const double xxl = 48.0;  // 6x   — separación mayor

  // ── Padding de pantalla ───────────────────────────────────────────────────
  static const double paddingPantalla = lg;  // 24dp

  // ── Bordes redondeados ────────────────────────────────────────────────────
  static const double radiusSmall  = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge  = 16.0;
  static const double radiusPill   = 20.0;

  // ── Alturas de componentes ────────────────────────────────────────────────
  static const double alturaBoton        = 52.0;
  static const double alturaInput        = 56.0;
  static const double alturaAppBar       = 56.0;
  static const double alturaTarjeta      = 80.0;
  static const double alturaFilaTabla    = 56.0;
  static const double alturaEncabezadoTabla = 48.0;

  // ── Tamaños de iconos ─────────────────────────────────────────────────────
  static const double iconoSmall  = 20.0;
  static const double iconoMedium = 24.0;
  static const double iconoLarge  = 48.0;

  // ── Tamaño mínimo táctil ──────────────────────────────────────────────────
  static const double minTactil = 48.0;

  // ── Separación entre campos de formulario ─────────────────────────────────
  static const double separacionCampos = md;  // 16dp

  // ── Separación entre tarjetas ─────────────────────────────────────────────
  static const double separacionTarjetas = sm;  // 8dp
}