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
    // El backend ahora manda 'rol' con valor granular:
    // 'jefe', 'empleado', 'recursos_materiales'
    // y 'rol_api' con 'autorizador' o 'solicitante'
    final String rolGranular = (json['rol'] ?? 'empleado').toString().toLowerCase();

    return AuthModel(
      token: json['token'] as String? ?? '',
      usuario: json['email'] as String? ?? '',
      rol: rolGranular,
      nombre: json['name'] as String? ?? '',
      correoPersonal: json['email'] as String? ?? '',
      correoPuesto: json['departamento'] as String? ?? '',
      idEmpleado: json['id_empleado_sam'] as int? ?? json['id'] as int? ?? 0,
      idDepartamento: json['id_departamento'] as int? ?? 0,
      puesto: json['rol_api'] as String? ?? rolGranular,
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
    'rol_api': puesto,
  };

  @override
  String toString() => json.encode(toJson());
}
