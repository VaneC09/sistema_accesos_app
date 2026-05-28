// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : vigilante_session_mixin.dart
// Módulo    : features/auth/presentation/mixins
// Autor     : Omega Company
// Fecha     : 2026-05-27
// Versión   : 1.2.0
// Descripción: Mixin para pantallas del vigilante.
//              Usa SesionEstado del proyecto.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../screens/vigilante_login_screen.dart';

mixin VigilanteSessionMixin<T extends StatefulWidget> on State<T> {
  void registrarActividad(BuildContext context) {
    context.read<AuthBloc>().registrarActividadVigilante();
  }

  void escucharSesion(BuildContext context, AuthState state) {
    if (state is AuthUnauthenticated) {
      final mensaje = state.motivo?.mensajeUsuario ??
          'Tu sesión ha sido cerrada. Vuelve a identificarte.';

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 5),
      ));

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const VigilanteLoginScreen()),
            (route) => false,
      );
    }
  }
}