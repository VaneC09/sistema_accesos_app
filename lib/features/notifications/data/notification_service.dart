// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : notification_service.dart
// Módulo    : features/notifications/data
// Autor     : Omega Company
// Fecha     : 2026-05-29
// Versión   : 2.0.0
// Descripción: Servicio de notificaciones push con Firebase + local — RF-023, RNF-04
//
// DEPENDENCIAS pubspec.yaml:
//   firebase_core: ^3.x
//   firebase_messaging: ^15.x
//   flutter_local_notifications: ^17.x
// =============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../core/errors/app_logger.dart';
import 'notification_model.dart';

// Importa Firebase solo si está disponible en el proyecto.
// Si aún no está integrado, deja los bloques TODO y usa el polling del Bloc.
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// ── Constantes de canal Android ───────────────────────────────────────────────

const _kCanalId     = 'accesos_visitas_canal';
const _kCanalNombre = 'Accesos y Visitas';
const _kCanalDesc   = 'Notificaciones de control de acceso';

// ── Handler de background (debe ser top-level) ────────────────────────────────
// @pragma('vm:entry-point')
// Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   NotificationService.instancia._procesarMensajeFirebase(message);
// }

// ─────────────────────────────────────────────────────────────────────────────

class NotificationService {
  static const String _modulo = 'NOTIFICATION_SERVICE';

  NotificationService._();
  static final NotificationService instancia = NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  // Callback invocado cuando el usuario toca una notificación local/push.
  // La UI escucha esto para navegar a la pantalla correcta.
  Function(NotificationModel)? onNotificacionTocada;

  // Callback invocado cuando llega una notificación en primer plano.
  Function(NotificationModel)? onNotificacionRecibida;

  bool _inicializado = false;

  // ── Inicializar ───────────────────────────────────────────────────────────

  Future<void> inicializar() async {
    if (_inicializado) return;

    await _inicializarNotificacionesLocales();

    // TODO: descomentar cuando Firebase esté integrado
    // FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    // await _inicializarFirebase();

    _inicializado = true;
    AppLogger.info(_modulo, 'NotificationService inicializado (modo polling)');
  }

  // ── Notificaciones locales ────────────────────────────────────────────────

  Future<void> _inicializarNotificacionesLocales() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onToqueNotificacionLocal,
    );

    // Crear canal de alta importancia en Android
    if (Platform.isAndroid) {
      const canal = AndroidNotificationChannel(
        _kCanalId,
        _kCanalNombre,
        description: _kCanalDesc,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(canal);
    }

    // Permisos iOS
    if (Platform.isIOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  void _onToqueNotificacionLocal(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    AppLogger.info(_modulo, 'Notificación local tocada — payload: $payload');

    try {
      // El payload es el tipo de notificación en string
      // La capa de UI usará este callback para navegar
      final notificacion = NotificationModel(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        tipo: _tipoDesdeString(payload),
        titulo: '',
        mensaje: '',
        fecha: DateTime.now(),
      );
      onNotificacionTocada?.call(notificacion);
    } catch (e) {
      AppLogger.error(_modulo, 'Error al procesar toque: $e');
    }
  }

  // ── Mostrar notificación local ────────────────────────────────────────────

  Future<void> mostrarNotificacionLocal({
    required String titulo,
    required String mensaje,
    required String tipo,       // valor de TipoNotificacion como string
    int? idNotificacion,
  }) async {
    AppLogger.info(_modulo, 'Mostrando notificación local: $titulo');

    const androidDetalles = AndroidNotificationDetails(
      _kCanalId,
      _kCanalNombre,
      channelDescription: _kCanalDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetalles = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const detalles = NotificationDetails(
      android: androidDetalles,
      iOS: iosDetalles,
    );

    await _localNotifications.show(
      idNotificacion ?? DateTime.now().millisecondsSinceEpoch % 100000,
      titulo,
      mensaje,
      detalles,
      payload: tipo,
    );
  }

  // ── Mostrar notificación accionable ───────────────────────────────────────
  // Método de conveniencia para los dos tipos clave del sistema.

  Future<void> notificarIngresoVisitante({
    required String nombreVisitante,
    required String area,
    int? idNotificacion,
  }) async {
    await mostrarNotificacionLocal(
      titulo: '🟢 Visitante en camino',
      mensaje:
      '$nombreVisitante acaba de ingresar${area.isNotEmpty ? ' por $area' : ''}.',
      tipo: 'visitante_ingreso',
      idNotificacion: idNotificacion,
    );
  }

  Future<void> notificarSolicitudExtension({
    required String nombreVisitante,
    required String folio,
    int? idNotificacion,
  }) async {
    await mostrarNotificacionLocal(
      titulo: '⚠️ Solicitud de tiempo extra',
      mensaje:
      '$nombreVisitante llegó fuera de horario ($folio). Revisa y decide si autorizar.',
      tipo: 'solicitud_extension',
      idNotificacion: idNotificacion,
    );
  }

  // ── Firebase (descomentar cuando esté integrado) ──────────────────────────

  // Future<void> _inicializarFirebase() async {
  //   final messaging = FirebaseMessaging.instance;
  //
  //   await messaging.requestPermission(alert: true, badge: true, sound: true);
  //
  //   // Primer plano
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     _procesarMensajeFirebase(message);
  //   });
  //
  //   // App en background, usuario toca notificación
  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //     _procesarMensajeFirebase(message, tocado: true);
  //   });
  //
  //   // App cerrada, usuario toca notificación
  //   final inicial = await messaging.getInitialMessage();
  //   if (inicial != null) {
  //     _procesarMensajeFirebase(inicial, tocado: true);
  //   }
  // }

  // void _procesarMensajeFirebase(RemoteMessage message, {bool tocado = false}) {
  //   AppLogger.info(_modulo, 'Mensaje Firebase: ${message.data}');
  //
  //   try {
  //     final datos = {
  //       ...message.data,
  //       'titulo': message.notification?.title ?? '',
  //       'mensaje': message.notification?.body  ?? '',
  //     };
  //
  //     final notificacion = NotificationModel.fromJson(datos);
  //
  //     if (tocado) {
  //       onNotificacionTocada?.call(notificacion);
  //     } else {
  //       onNotificacionRecibida?.call(notificacion);
  //       // Mostrar cabecera local mientras la app está en primer plano
  //       mostrarNotificacionLocal(
  //         titulo: notificacion.titulo,
  //         mensaje: notificacion.mensaje,
  //         tipo: message.data['tipo'] ?? '',
  //       );
  //     }
  //   } catch (e) {
  //     AppLogger.error(_modulo, 'Error procesando mensaje Firebase: $e');
  //   }
  // }

  // ── Token FCM ─────────────────────────────────────────────────────────────

  Future<String?> obtenerToken() async {
    // TODO: return await FirebaseMessaging.instance.getToken();
    AppLogger.info(_modulo, 'Token FCM — usando polling como alternativa');
    return null;
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  TipoNotificacion _tipoDesdeString(String tipo) {
    switch (tipo) {
      case 'visitante_ingreso':
        return TipoNotificacion.visitanteIngreso;
      case 'solicitud_extension':
        return TipoNotificacion.solicitudExtension;
      case 'qr_expirado_tolerancia':
        return TipoNotificacion.qrExpiradoTolerancia;
      case 'visitante_salida':
        return TipoNotificacion.visitanteSalida;
      case 'autorizada':
      case 'solicitud_autorizada':
        return TipoNotificacion.solicitudAutorizada;
      case 'rechazada':
      case 'solicitud_rechazada':
        return TipoNotificacion.solicitudRechazada;
      default:
        return TipoNotificacion.nuevaSolicitudPendiente;
    }
  }
}