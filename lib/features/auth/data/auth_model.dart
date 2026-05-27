// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : auth_model.dart
// Módulo    : features/auth/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// =============================================================================
import 'dart:convert';

class AuthModel {
  final String token;
  final String usuario;
  final String rol;
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
    final String rol = (json['rol'] ?? 'solicitante').toString().toLowerCase();

    return AuthModel(
      token: json['token'] as String? ?? '',
      usuario: json['usuario'] as String? ?? '',
      rol: rol,
      nombre: json['name'] as String? ?? '',
      correoPersonal: json['email'] as String? ?? '',
      correoPuesto: json['correo_puesto'] as String? ?? '',
      idEmpleado: json['id'] as int? ?? 0,
      idDepartamento: json['id_departamento'] as int? ?? 0,
      puesto: rol,
    );
  }

  factory AuthModel.fromString(String jsonString) {
    return AuthModel.fromJson(json.decode(jsonString) as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'usuario': usuario,
    'rol': rol,
    'name': nombre,
    'email': correoPersonal,
    'correo_puesto': correoPuesto,
    'id': idEmpleado,
    'id_departamento': idDepartamento,
  };

  @override
  String toString() => json.encode(toJson());
}

