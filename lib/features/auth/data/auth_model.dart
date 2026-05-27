// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : auth_model.dart
// Módulo    : features/auth/data
// Autor     : Omega Company
// Fecha     : 2026-05-26
// Versión   : 1.1.0
// =============================================================================
import 'dart:convert';

class AuthModel {
  final String token;
  final String usuario;
  final String rol;      // 'autorizador', 'solicitante', 'vigilante'
  final String nombre;
  final String correoPersonal;
  final String correoPuesto;
  final int idEmpleado;
  final int idDepartamento;
  final String puesto;

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
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    // El backend manda exactamente: 'autorizador', 'solicitante', 'vigilante'
    // en el campo 'rol'. No se transforma, se usa directo.
    final String rol = (json['rol'] ?? 'solicitante').toString().toLowerCase().trim();

    return AuthModel(
      token:          json['token']           as String? ?? '',
      usuario:        json['email']           as String? ?? '',
      rol:            rol,
      nombre:         json['name']            as String? ?? '',
      correoPersonal: json['email']           as String? ?? '',
      correoPuesto:   json['departamento']    as String? ?? '',
      idEmpleado:     json['id_empleado_sam'] as int?
          ?? json['id']           as int? ?? 0,
      idDepartamento: json['id_departamento'] as int? ?? 0,
      puesto:         json['rol_api']         as String? ?? rol,
    );
  }

  factory AuthModel.fromString(String jsonString) {
    return AuthModel.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'token':           token,
    'email':           usuario,   // ← clave 'email' para que fromJson la lea bien
    'rol':             rol,
    'name':            nombre,
    'departamento':    correoPuesto,
    'id_empleado_sam': idEmpleado,
    'id_departamento': idDepartamento,
    'rol_api':         puesto,
  };

  @override
  String toString() => json.encode(toJson());
}