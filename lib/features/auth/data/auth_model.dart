// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : auth_model.dart
// Módulo    : features/auth/data
// Autor     : Omega Company
// Fecha     : 2026-05-29
// Versión   : 1.3.0
// Correcciones:
//   - Conserva telefono y area para vigilante.
//   - Agrega roles para usuarios con más de un rol.
// =============================================================================

import 'dart:convert';

class AuthModel {
  final String token;
  final String usuario;
  final String rol;
  final String rolApi;
  final List<String> roles;
  final String nombre;
  final String correoPersonal;
  final String correoPuesto;
  final int idEmpleado;
  final int idDepartamento;
  final String puesto;

  // Campos exclusivos del vigilante
  final String telefono;
  final String area;

  const AuthModel({
    required this.token,
    required this.usuario,
    required this.rol,
    required this.rolApi,
    required this.roles,
    required this.nombre,
    required this.correoPersonal,
    required this.correoPuesto,
    required this.idEmpleado,
    required this.idDepartamento,
    required this.puesto,
    this.telefono = '',
    this.area = '',
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final String rol =
    (json['rol'] ?? 'solicitante').toString().toLowerCase().trim();

    final String rolApi =
    (json['rol_api'] ?? rol).toString().toLowerCase().trim();

    final List<String> roles = (json['roles'] as List<dynamic>?)
        ?.map((e) => e.toString().toLowerCase().trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList() ??
        [rol];

    if (!roles.contains(rol)) {
      roles.add(rol);
    }

    return AuthModel(
      token: (json['token'] as String?) ?? '',
      usuario: (json['email'] as String?) ?? '',
      rol: rol,
      rolApi: rolApi,
      roles: roles,
      nombre: (json['name'] as String?) ?? '',
      correoPersonal: (json['email'] as String?) ?? '',
      correoPuesto: (json['departamento'] as String?) ?? '',
      idEmpleado: (json['id_empleado_sam'] as int?) ??
          (json['id'] as int?) ??
          0,
      idDepartamento: (json['id_departamento'] as int?) ?? 0,
      puesto: rolApi,
      telefono: (json['telefono'] as String?) ?? '',
      area: (json['area'] as String?) ?? '',
    );
  }

  factory AuthModel.fromString(String jsonString) {
    return AuthModel.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  AuthModel copyWithVigilante({
    required String telefono,
    required String area,
  }) {
    return AuthModel(
      token: token,
      usuario: usuario,
      rol: rol,
      rolApi: rolApi,
      roles: roles,
      nombre: nombre,
      correoPersonal: correoPersonal,
      correoPuesto: correoPuesto,
      idEmpleado: idEmpleado,
      idDepartamento: idDepartamento,
      puesto: puesto,
      telefono: telefono,
      area: area,
    );
  }

  bool get tieneTokenSanctum => token.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'token': token,
    'email': usuario,
    'rol': rol,
    'rol_api': rolApi,
    'roles': roles,
    'name': nombre,
    'departamento': correoPuesto,
    'id_empleado_sam': idEmpleado,
    'id_departamento': idDepartamento,
    'puesto': puesto,
    'telefono': telefono,
    'area': area,
  };

  @override
  String toString() => json.encode(toJson());
}