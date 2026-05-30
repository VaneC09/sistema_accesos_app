// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : filtro_estado_solicitud.dart
// Módulo    : core/constants
// Descripción: Chips y mapeo de filtros por estado de solicitud.
// =============================================================================

class FiltroEstadoSolicitud {
  FiltroEstadoSolicitud._();

  static const String todos = 'Todos';
  static const String pendiente = 'Pendiente';
  static const String autorizada = 'Autorizada';
  static const String rechazada = 'Rechazada';
  static const String cancelada = 'Cancelada';

  static const List<String> chips = [
    todos,
    pendiente,
    autorizada,
    rechazada,
    cancelada,
  ];

  /// Valor API para GET /solicitudes?estado=
  static String? parametroSolicitudes(String? chip) {
    if (chip == null || chip == todos) return null;
    return chip.toLowerCase();
  }

  /// Valor API para GET /autorizador/solicitudes?filtro=
  static String parametroAutorizador(String? chip) {
    if (chip == null || chip == todos) return 'todos';
    switch (chip) {
      case pendiente:
        return 'pendientes';
      case autorizada:
        return 'autorizadas';
      case rechazada:
        return 'rechazadas';
      case cancelada:
        return 'canceladas';
      default:
        return 'todos';
    }
  }

  /// Valor API para GET /notificaciones?estado=
  static String? parametroNotificaciones(String? chip) {
    return parametroSolicitudes(chip);
  }

  /// Compara un chip UI con el estado de un registro de solicitud/autorización.
  static bool coincideEstado(String? chip, String estadoRegistro) {
    if (chip == null || chip == todos) return true;
    return chip.toLowerCase() == _normalizarTextoEstado(estadoRegistro);
  }

  static String _normalizarTextoEstado(String estado) {
    final texto = estado.toLowerCase().trim();

    if (texto == 'aprobada' || texto == 'aprobado') {
      return autorizada.toLowerCase();
    }
    if (texto.startsWith('pendient')) return pendiente.toLowerCase();
    if (texto.startsWith('autoriz') || texto.startsWith('aprob')) {
      return autorizada.toLowerCase();
    }
    if (texto.startsWith('rechaz')) return rechazada.toLowerCase();
    if (texto.startsWith('cancel')) return cancelada.toLowerCase();

    return texto;
  }
}
