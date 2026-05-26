// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : app_config.dart
// Módulo    : core/config
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Configuración global de la aplicación — MPF-OMEGA-04 §6.5
// =============================================================================

class AppConfig {
  AppConfig._();

  // ── Entorno ───────────────────────────────────────────────────────────────
  static const bool esProduccion = true; // ← true para producción

  // ── URL base de la API Laravel ────────────────────────────────────────────
  // DEV: cambia a la IP de tu servidor Laravel local
  static const String baseUrlDev = 'http://10.0.2.2:8000/api';
  static const String baseUrlProd = 'https://decade-trapdoor-wafer.ngrok-free.dev/api';

  static String get baseUrl => esProduccion ? baseUrlProd : baseUrlDev;

  // ── Timeouts ──────────────────────────────────────────────────────────────
  static const int timeoutConexionSegundos = 10;
  static const int timeoutRespuestaSegundos = 15;

  // ── Reintentos ────────────────────────────────────────────────────────────
  static const int maxReintentos = 2;

  // ── Sesión ────────────────────────────────────────────────────────────────
  static const int minutosInactividad = 30;
  static const int maxIntentosFallidos = 5;

  // ── QR ────────────────────────────────────────────────────────────────────
  static const int toleranciaDefaultMinutos = 15;
  static const int maxReenviosQr = 3;

  // ── Dominio institucional ─────────────────────────────────────────────────
  static const String dominioInstitucional = '@toluca.tecnm.mx';

  // ── Áreas del vigilante ───────────────────────────────────────────────────
  static const List<String> areasVigilante = [
    'Entrada vehicular 1',
    'Entrada vehicular 2',
    'Entrada vehicular 4',
    'Entrada vehicular 5',
    'Entrada peatonal principal',
  ];

  // ── Claves de almacenamiento seguro ───────────────────────────────────────
  static const String claveToken = 'access_token';
  static const String claveRefreshToken = 'refresh_token';
  static const String claveUsuario = 'usuario_data';
  static const String claveRol = 'usuario_rol';
}