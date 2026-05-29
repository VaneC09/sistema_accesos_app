// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : auth_model.dart
// Módulo    : features/auth/data
// Autor     : Omega Company
// Fecha     : 2026-05-29
// Versión   : 1.2.0
// Correcciones:
//   - Añadidos campos `telefono` y `area` para el flujo de vigilante.
//     El servidor no los devuelve, se inyectan desde el Bloc tras el login.
// =============================================================================
import 'dart:convert';

class AuthModel {
  final String token;
  final String usuario;
  final String rol;
  final String nombre;
  final String correoPersonal;
  final String correoPuesto;
  final int    idEmpleado;
  final int    idDepartamento;
  final String puesto;

  // ── Campos exclusivos del vigilante (no vienen del servidor) ──────────────
  final String telefono;   // ← NUEVO
  final String area;       // ← NUEVO

  const AuthModel({
    required this.token,
    required this.usuario,
    required this.rol,
    required this.nombre,
    required this.correoPersonal,
    required this.correoPuesto,
    required this.idEmpleado,
    required this.idDepartamento,
    required this.puesto,
    this.telefono = '',    // ← NUEVO (opcional, vacío para empleados)
    this.area     = '',    // ← NUEVO (opcional, vacío para empleados)
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final String rol =
    (json['rol'] ?? 'solicitante').toString().toLowerCase().trim();

    return AuthModel(
      token:          (json['token']           as String?) ?? '',
      usuario:        (json['email']           as String?) ?? '',
      rol:            rol,
      nombre:         (json['name']            as String?) ?? '',
      correoPersonal: (json['email']           as String?) ?? '',
      correoPuesto:   (json['departamento']    as String?) ?? '',
      idEmpleado:     (json['id_empleado_sam'] as int?)
          ?? (json['id']          as int?) ?? 0,
      idDepartamento: (json['id_departamento'] as int?) ?? 0,
      puesto:         (json['rol_api']         as String?) ?? rol,
      // telefono y area NO vienen del servidor → quedan en '' por defecto
    );
  }

  factory AuthModel.fromString(String jsonString) =>
      AuthModel.fromJson(json.decode(jsonString) as Map<String, dynamic>);

  /// Crea una copia con `telefono` y `area` sobreescritos.
  /// Usado en AuthBloc._onLoginVigilante para inyectarlos antes de persistir.
  AuthModel copyWithVigilante({
    required String telefono,
    required String area,
  }) =>
      AuthModel(
        token:          token,
        usuario:        usuario,
        rol:            rol,
        nombre:         nombre,
        correoPersonal: correoPersonal,
        correoPuesto:   correoPuesto,
        idEmpleado:     idEmpleado,
        idDepartamento: idDepartamento,
        puesto:         puesto,
        telefono:       telefono,
        area:           area,
      );

  bool get tieneTokenSanctum => token.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'token':           token,
    'email':           usuario,
    'rol':             rol,
    'name':            nombre,
    'departamento':    correoPuesto,
    'id_empleado_sam': idEmpleado,
    'id_departamento': idDepartamento,
    'rol_api':         puesto,
    'telefono':        telefono,  // ← NUEVO
    'area':            area,      // ← NUEVO
  };

  @override
  String toString() => json.encode(toJson());
}