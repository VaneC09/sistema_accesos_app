// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : app_strings.dart
// Módulo    : core/constants
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Cadenas de texto centralizadas — MPF-OMEGA-04 §6.4
// =============================================================================

class AppStrings {
  AppStrings._();

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String tituloApp = 'Sistema de Accesos ITT';
  static const String subtituloLogin = 'Ingresa tus credenciales institucionales';
  static const String campoUsuario = 'Usuario institucional';
  static const String hintUsuario = 'usuario@toluca.tecnm.mx';
  static const String campoContrasena = 'Contraseña';
  static const String botonIniciarSesion = 'Iniciar sesión';
  static const String botonAccesoVigilante = 'Acceso para vigilantes';
  static const String tituloVigilante = 'Acceso Vigilante';
  static const String subtituloVigilante = 'Registra tu número y área asignada';
  static const String campoTelefono = 'Número de teléfono';
  static const String hintTelefono = '7221234567';
  static const String campoArea = 'Área asignada';
  static const String botonRegistrarAcceso = 'Registrar acceso';

  // ── Errores de auth ───────────────────────────────────────────────────────
  static const String errorCamposVacios =
      'Debe ingresar usuario y contraseña institucional';
  static const String errorCredencialesInvalidas =
      'Credenciales inválidas. Intente nuevamente';
  static const String errorAccesoBloqueado =
      'Acceso bloqueado por múltiples intentos fallidos';
  static const String errorSesionInactiva = 'Sesión cerrada por inactividad';
  static const String errorTokenInvalido =
      'Su sesión ha expirado. Inicie sesión nuevamente';
  static const String errorDominioInvalido =
      'El correo debe ser del dominio @toluca.tecnm.mx';
  static const String errorCamposVigilante =
      'Debe ingresar número de teléfono y área asignada';

  // ── Sesión ────────────────────────────────────────────────────────────────
  static const String preguntaCerrarSesion = '¿Desea cerrar su sesión?';
  static const String botonCerrarSesion = 'Cerrar sesión';
  static const String botonCancelar = 'Cancelar';
  static const String errorCierreSesion =
      'No fue posible cerrar la sesión. Intente nuevamente';

  // ── Home ──────────────────────────────────────────────────────────────────
  static const String preguntaAccion = '¿Qué deseas hacer?';
  static const String menuNuevaSolicitud = 'Nueva solicitud';
  static const String menuMisSolicitudes = 'Mis solicitudes';
  static const String menuAutorizarVisitas = 'Autorizar visitas';
  static const String menuNotificaciones = 'Notificaciones';
  static const String menuEscanearQr = 'Escanear QR';
  static const String menuVisitasHoy = 'Visitas de hoy';
  static const String menuRegistroManual = 'Registro manual';

  // ── Solicitudes ───────────────────────────────────────────────────────────
  static const String tituloNuevaSolicitud = 'Nueva solicitud';
  static const String labelTipoVisita = 'Tipo de visita';
  static const String labelVisitaGrupal = 'Visita grupal';
  static const String labelNombreVisitante = 'Nombre del visitante';
  static const String labelCorreoVisitante = 'Correo del visitante';
  static const String labelLugarDestino = 'Lugar destino';
  static const String labelFecha = 'Fecha';
  static const String labelHora = 'Hora';
  static const String labelMotivo = 'Motivo de visita';
  static const String labelToleranciaAntes = 'Antes (min)';
  static const String labelToleranciaDespues = 'Después (min)';
  static const String labelToleranciaLlegada = 'Tolerancia de llegada';
  static const String botonEnviarSolicitud = 'Enviar solicitud';
  static const String botonAgregarVisitante = 'Agregar visitante';

  // ── Errores de solicitud ──────────────────────────────────────────────────
  static const String errorCamposIncompletos =
      'Complete todos los datos requeridos';
  static const String errorNombreMinimo =
      'Ingrese un nombre válido (mínimo 5 caracteres)';
  static const String errorCorreoInvalido = 'Ingrese un correo válido';
  static const String errorCorreoDuplicado =
      'No se permiten correos duplicados en el grupo';
  static const String errorTipoVisita = 'Seleccione el tipo de visitante';
  static const String errorDepartamento =
      'Seleccione el departamento destino';
  static const String errorSolicitudFallida =
      'No fue posible crear la solicitud. Intente nuevamente';
  static const String errorCatalogoNoDisponible =
      'No fue posible cargar los datos. Intente nuevamente';

  // ── Estados de solicitud ──────────────────────────────────────────────────
  static const String estadoPendiente = 'Pendiente';
  static const String estadoAutorizada = 'Autorizada';
  static const String estadoRechazada = 'Rechazada';
  static const String estadoCancelada = 'Cancelada';

  // ── Éxito de solicitud ────────────────────────────────────────────────────
  static const String solicitudEnviada = 'Solicitud enviada';
  static const String solicitudRegistrada =
      'Visita registrada correctamente.\nFolio: ';

  // ── Autorización ──────────────────────────────────────────────────────────
  static const String tituloAutorizaciones = 'Autorizar visitas';
  static const String botonAutorizar = 'Autorizar';
  static const String botonRechazar = 'Rechazar';
  static const String solicitudYaAutorizada = 'La solicitud ya fue autorizada';
  static const String exitoAutorizacion =
      'Su solicitud ha sido autorizada. Ya puedes enviar el código QR a tu visitante';
  static const String exitoRechazo = 'Su solicitud fue rechazada';

  // ── QR ────────────────────────────────────────────────────────────────────
  static const String preguntaEnviarQr =
      '¿Desea enviar el pase QR al visitante?';
  static const String botonMandar = 'Mandar';
  static const String exitoEnvioQr =
      'Se envió el pase QR con instrucciones de acceso.';
  static const String errorEnvioQr =
      'No fue posible enviar el pase. Intente más tarde.';
  static const String exitoExtensionQr =
      'La vigencia del pase QR ha sido extendida.';
  static const String errorExtensionQr =
      'No fue posible extender la vigencia del QR.';
  static const String limiteReenvios =
      'Ha alcanzado el límite de 3 reenvíos para esta solicitud. Contacte al administrador si necesita asistencia';

  // ── Control de acceso ─────────────────────────────────────────────────────
  static const String tituloEscanerQr = 'Escanear QR';
  static const String tituloVisitasHoy = 'Visitas de hoy';
  static const String accesoPermitido = 'Acceso permitido';
  static const String accesoDenegado = 'Acceso denegado';
  static const String accesoFueraHorario = 'Acceso fuera del horario permitido.';
  static const String qrVencidoHora = 'Código vencido por hora';
  static const String qrVencidoFecha = 'Código vencido por fecha';
  static const String qrVencidoTolerancia = 'Código vencido por tolerancia';
  static const String errorListaExclusion =
      'Acceso denegado: visitante en lista de exclusión. No permitir ingreso';
  static const String errorValidacionExclusion =
      'No fue posible validar exclusión. Acceso denegado por precaución';
  static const String exitoEntrada = 'Entrada registrada correctamente';
  static const String exitoSalida = 'Salida registrada correctamente';
  static const String errorRegistroSalida =
      'No fue posible registrar salida';

  // ── Notificaciones ────────────────────────────────────────────────────────
  static const String notifSolicitudAutorizada =
      'Su solicitud ha sido autorizada.';
  static const String notifSolicitudRechazada =
      'Su solicitud fue rechazada.';
  static const String notifVisitanteIngreso =
      'El visitante ha ingresado al campus';
  static const String notifPermanenciaExcedida =
      'El visitante excede tiempo permitido en campus';
  static const String notifSolicitudCancelada =
      'Tu solicitud fue cancelada automáticamente por no recibir autorización';

  // ── Confirmación de visita ────────────────────────────────────────────────
  static const String exitoConfirmacionLlegada = 'Visita confirmada en oficina';
  static const String errorConfirmacionLlegada =
      'No fue posible registrar llegada';
  static const String errorConfirmacionSalida =
      'No fue posible registrar salida';

  // ── General ───────────────────────────────────────────────────────────────
  static const String botonAceptar = 'Aceptar';
  static const String botonVolver = 'Volver';
  static const String botonGuardar = 'Guardar';
  static const String botonEnviar = 'Enviar';
  static const String labelEnConstruccion = 'En construcción';
  static const String errorGeneral =
      'Ocurrió un error inesperado. Intente nuevamente';
  static const String errorSinConexion =
      'Sin conexión. Verifique su red e intente nuevamente';
}