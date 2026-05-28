// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : app_config.dart
// Módulo    : core/config
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Configuración global de la aplicación — MPF-OMEGA-04 §6.5
// =============================================================================
// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : app_config.dart
// Módulo    : core/config
// Autor     : Omega Company
// Fecha     : 2026-05-27
// Versión   : 1.2.0
// Cambio    : Se añaden claveTelefonoVigilante, claveAreaVigilante y
//             horasJornadaLaboral. El resto sin cambios.
// =============================================================================

class AppConfig {
  AppConfig._();

  static const bool esProduccion = true;

  static const String baseUrlDev  = 'http://10.0.2.2:8000/api';
  static const String baseUrlProd = 'https://decade-trapdoor-wafer.ngrok-free.dev/api';
  static String get baseUrl => esProduccion ? baseUrlProd : baseUrlDev;

  static const int timeoutConexionSegundos  = 10;
  static const int timeoutRespuestaSegundos = 15;
  static const int maxReintentos            = 2;

  // Sesión general
  static const int minutosInactividad  = 30;
  static const int maxIntentosFallidos = 5;

  // Sesión vigilante
  static const int horasJornadaLaboral = 7;

  static const int toleranciaDefaultMinutos = 15;
  static const int maxReenviosQr            = 3;

  static const String dominioInstitucional = '@toluca.tecnm.mx';

  static const List<String> areasVigilante = [
    'Entrada vehicular 1',
    'Entrada vehicular 2',
    'Entrada vehicular 3',
    'Entrada vehicular 4',
    'Entrada vehicular 5',
    'Entrada peatonal principal',
  ];

  // Claves de almacenamiento seguro
  static const String claveToken              = 'access_token';
  static const String claveRefreshToken       = 'refresh_token';
  static const String claveUsuario            = 'usuario_data';
  static const String claveRol                = 'usuario_rol';
  static const String claveInicioJornada      = 'vigilante_inicio_jornada';

  // Claves exclusivas del vigilante (teléfono y área para incluir en peticiones)
  static const String claveTelefonoVigilante  = 'vigilante_telefono';
  static const String claveAreaVigilante      = 'vigilante_area';
}