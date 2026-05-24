// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : app_colors.dart
// Módulo    : core/constants
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Paleta de colores institucional OMEGA — MPF-OMEGA-04 §7.7.1
// =============================================================================

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Nivel 0 — Fondos principales
  static const Color baseSurface   = Color(0xFFFFFDFC);
  // Nivel 1 — Cards, Drawer, inputs deshabilitados
  static const Color surface       = Color(0xFFEBE1DF);
  // Interacción — Filas cebra, selección activa
  static const Color subtleWarm    = Color(0xFFFAEFED);

  // Marca / Énfasis — Botón primario, iconos activos
  static const Color primaryCoral  = Color(0xFFF28B66);
  // Informativo — Cabeceras de tablas
  static const Color headingSky    = Color(0xFF9ABBC9);
  // Soporte — Badges, estados secundarios
  static const Color cloudBlue     = Color(0xFFD2ECF7);

  // Estado: Éxito
  static const Color successGreen  = Color(0xFF10B981);
  // Crítico / Error
  static const Color actionRed     = Color(0xFFD77552);
  // Advertencia
  static const Color warningOrange = Color(0xFFFFAE91);

  // Tipografía — Títulos H1
  static const Color deepNavy      = Color(0xFF233B54);
  // Navegación — Iconos inactivos, borde input en foco
  static const Color headingDark   = Color(0xFF517399);
  // Labels de formularios
  static const Color steelBlue     = Color(0xFF405A75);
  // Cuerpo de texto principal
  static const Color onyxGrey      = Color(0xFF303030);

  static const Color pureBlack     = Color(0xFF000000);
  static const Color neutralGrey   = Color(0xFF595959);
}