// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : vigilante_login_screen.dart
// Módulo    : features/auth/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Pantalla de acceso para vigilantes — RF-009
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth_bloc.dart';
import '../../presentation/widgets/auth_header_widget.dart';
import '../../presentation/screens/home_screen.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/primary_button_widget.dart';

class VigilanteLoginScreen extends StatefulWidget {
  const VigilanteLoginScreen({super.key});

  @override
  State<VigilanteLoginScreen> createState() => _VigilanteLoginScreenState();
}

class _VigilanteLoginScreenState extends State<VigilanteLoginScreen> {
  final _telefonoController = TextEditingController();
  String _areaSeleccionada = '';

  @override
  void dispose() {
    _telefonoController.dispose();
    super.dispose();
  }

  void _onAccesoPressed() {
    context.read<AuthBloc>().add(
      LoginVigilante(
        telefono: _telefonoController.text.trim(),
        area: _areaSeleccionada,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseSurface,
      appBar: AppBar(
        backgroundColor: AppColors.baseSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.headingDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: AppColors.actionRed,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.paddingPantalla),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Encabezado
                AuthHeaderWidget(
                  icono: Icons.security_rounded,
                  titulo: AppStrings.tituloVigilante,
                  subtitulo: AppStrings.subtituloVigilante,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Campo teléfono
                TextField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    labelText: AppStrings.campoTelefono,
                    hintText: AppStrings.hintTelefono,
                    prefixIcon: Icon(Icons.phone_outlined),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Selector de área
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: AppStrings.campoArea,
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  items: AppConfig.areasVigilante
                      .map((area) => DropdownMenuItem(
                    value: area,
                    child: Text(area),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _areaSeleccionada = value ?? '';
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                // Botón acceso
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return PrimaryButtonWidget(
                      texto: AppStrings.botonRegistrarAcceso,
                      cargando: state is AuthLoading,
                      onPressed: _onAccesoPressed,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}