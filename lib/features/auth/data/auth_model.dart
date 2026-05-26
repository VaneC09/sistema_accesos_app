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

  // Constructor para mapear el JSON proveniente del Backend u origen de datos
  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final String rolBackend = (json['rol'] ?? json['role'] ?? 'solicitante').toString().toLowerCase();

    String rolApp;
    switch (rolBackend) {
      case 'autorizador':
      case 'jefe':
        rolApp = 'jefe';
        break;
      case 'vigilante':
        rolApp = 'vigilante';
        break;
      default:
        rolApp = 'empleado';
    }

    return AuthModel(
      token: json['token'] as String? ?? '',
      usuario: json['email'] as String? ?? '',
      rol: rolApp,
      nombre: json['name'] as String? ?? '',
      correoPersonal: json['email'] as String? ?? '',
      correoPuesto: json['correo_puesto'] as String? ?? '',
      idEmpleado: json['id'] as int? ?? 0,
      idDepartamento: json['id_departamento'] as int? ?? 0,
      puesto: rolBackend,
    );
  }

  // Constructor requerido por el repositorio para leer strings de persistencia local
  factory AuthModel.fromString(String jsonString) {
    return AuthModel.fromJson(json.decode(jsonString) as Map<String, dynamic>);
  }

  // Método útil por si el repositorio requiere guardar el modelo como String posteriormente
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'email': usuario,
      'rol': puesto, // Guarda el rol original del backend
      'name': nombre,
      'correo_puesto': correoPuesto,
      'id': idEmpleado,
      'id_departamento': idDepartamento,
    };
  }
}