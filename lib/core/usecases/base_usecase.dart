// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : base_usecase.dart
// Módulo    : core/usecases
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Caso de uso base reutilizable — MPF-OMEGA-04 §6.1
// =============================================================================

// Caso de uso con parámetros
abstract class BaseUseCase<Tipo, Parametros> {
  Future<Tipo> ejecutar(Parametros parametros);
}

// Caso de uso sin parámetros
abstract class BaseUseCaseSinParametros<Tipo> {
  Future<Tipo> ejecutar();
}

// Parámetros vacíos para casos de uso sin entrada
class SinParametros {
  const SinParametros();
}