// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : login_screen.dart
// Módulo    : features/auth/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Pantalla de inicio de sesión — RF-009, RF-010, RF-011, RF-012
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth_bloc.dart';
import '../../presentation/widgets/auth_header_widget.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/vigilante_login_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/primary_button_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usuarioController = TextEditingController();
  final _contrasenaController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    context.read<AuthBloc>().add(
      LoginSubmitted(
        usuario: _usuarioController.text.trim(),
        contrasena: _contrasenaController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseSurface,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          } else if (state is AuthBlocked) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.errorAccesoBloqueado),
                backgroundColor: AppColors.actionRed,
              ),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.paddingPantalla),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Encabezado
                  AuthHeaderWidget(
                    icono: Icons.lock_outline_rounded,
                    titulo: AppStrings.tituloApp,
                    subtitulo: AppStrings.subtituloLogin,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Campo usuario
                  TextField(
                    controller: _usuarioController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: AppStrings.campoUsuario,
                      hintText: AppStrings.hintUsuario,
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Campo contraseña
                  TextField(
                    controller: _contrasenaController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: AppStrings.campoContrasena,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Botón iniciar sesión
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return PrimaryButtonWidget(
                        texto: AppStrings.botonIniciarSesion,
                        cargando: state is AuthLoading,
                        onPressed: _onLoginPressed,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Botón vigilante
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VigilanteLoginScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.security_rounded,
                      color: AppColors.headingDark,
                    ),
                    label: const Text(
                      AppStrings.botonAccesoVigilante,
                      style: TextStyle(color: AppColors.headingDark),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Mensaje de error
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthError) {
                        return Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.warningOrange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSmall,
                            ),
                            border: Border.all(color: AppColors.actionRed),
                          ),
                          child: Text(
                            state.mensaje,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.actionRed,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}