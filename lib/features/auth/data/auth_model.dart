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
    return AuthModel(
      token: json['token'] as String? ?? '',
      usuario: json['usuario'] as String? ?? '',
      rol: json['rol'] as String? ?? 'empleado',
      nombre: json['nombre'] as String? ?? '',
      correoPersonal: json['correo_personal'] as String? ?? '',
      correoPuesto: json['correo_puesto'] as String? ?? '',
      idEmpleado: json['id_empleado'] as int? ?? 0,
      idDepartamento: json['id_departamento'] as int? ?? 0,
      puesto: json['puesto'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'usuario': usuario,
      'rol': rol,
      'nombre': nombre,
      'correo_personal': correoPersonal,
      'correo_puesto': correoPuesto,
      'id_empleado': idEmpleado,
      'id_departamento': idDepartamento,
      'puesto': puesto,
    };
  }

  factory AuthModel.fromString(String jsonStr) {
    try {
      final mapa = jsonDecode(jsonStr) as Map<String, dynamic>;
      return AuthModel.fromJson(mapa);
    } catch (e) {
      throw Exception('Error al parsear sesión guardada: $e');
    }
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}