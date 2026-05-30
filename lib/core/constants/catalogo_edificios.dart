// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : catalogo_edificios.dart
// Módulo    : core/constants
// Descripción: Respaldo local de edificios por escuela (plantel).
// =============================================================================

import '../../features/visit_request/data/visit_request_model.dart';

class CatalogoEdificios {
  CatalogoEdificios._();

  static const int escuelaToluca = 1;

  static const Map<int, List<CatalogoModel>> _porEscuela = {
    escuelaToluca: [
      CatalogoModel(id: 1, nombre: 'Edificio A'),
      CatalogoModel(id: 2, nombre: 'Edificio B'),
      CatalogoModel(id: 3, nombre: 'Edificio T'),
      CatalogoModel(id: 4, nombre: 'Edificio de Desarrollo Académico'),
      CatalogoModel(id: 5, nombre: 'Dirección'),
      CatalogoModel(id: 6, nombre: 'División de Comunicación y Difusión'),
      CatalogoModel(id: 7, nombre: 'Recursos Materiales'),
      CatalogoModel(id: 8, nombre: 'Entrada principal'),
      CatalogoModel(id: 9, nombre: 'Entrada lateral'),
    ],
  };

  static List<CatalogoModel> porEscuela(int idEscuela) {
    return List.unmodifiable(
      _porEscuela[idEscuela] ?? _porEscuela[escuelaToluca]!,
    );
  }

  static String nombreEscuela(int idEscuela) {
    switch (idEscuela) {
      case escuelaToluca:
        return 'Instituto Tecnológico de Toluca';
      default:
        return 'Instituto Tecnológico de Toluca';
    }
  }
}
