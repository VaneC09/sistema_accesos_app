// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : safe_scaffold_body_widget.dart
// Módulo    : core/widgets
// Descripción: Reserva espacio para la barra de navegación del sistema Android.
// =============================================================================

import 'package:flutter/material.dart';

/// Evita que listas, paginación o botones queden detrás de los
/// 3 botones de navegación del celular (o la barra gestual).
class SafeScaffoldBody extends StatelessWidget {
  final Widget child;

  const SafeScaffoldBody({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final insetoInferior = MediaQuery.viewPaddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: insetoInferior),
      child: child,
    );
  }
}
