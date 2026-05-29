// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : vigilante_login_screen.dart
// Módulo    : features/auth/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-27
// Versión   : 1.3.0
// Correcciones:
//   - phone_number_hint devuelve "+52" sin número real cuando la SIM no
//     tiene número registrado → se descarta y el campo queda vacío para
//     ingreso manual (ya no muestra "52" en el campo).
//   - Validación local corregida: no deja pasar si longitud < 10 dígitos.
//   - BlocListener maneja AuthUnauthenticated con motivo (sesión expirada).
// =============================================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth_bloc.dart';
import '../../presentation/widgets/auth_header_widget.dart';
import '../../presentation/screens/home_screen.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/primary_button_widget.dart';
import 'phone_resolver.dart';   // ← import del helper

class VigilanteLoginScreen extends StatefulWidget {
  const VigilanteLoginScreen({super.key});

  @override
  State<VigilanteLoginScreen> createState() => _VigilanteLoginScreenState();
}

class _VigilanteLoginScreenState extends State<VigilanteLoginScreen> {
  final _telefonoController = TextEditingController();

  // PhoneNumberHint ya no se instancia aquí, lo maneja PhoneResolver
  String _areaSeleccionada = '';
  bool   _telefonoTocado   = false;
  bool   _areaTocada       = false;
  bool   _buscandoNumero   = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _pedirNumeroSIM());
  }

  @override
  void dispose() {
    _telefonoController.dispose();
    super.dispose();
  }

// ── Obtener número del dispositivo ────────────────────────────────────────
  Future<void> _pedirNumeroSIM() async {
    setState(() => _buscandoNumero = true);
    try {
      final result = await PhoneResolver.resolver();

      if (!mounted) return;

      // if/else en lugar de switch para compatibilidad con SDK >=3.0
      if (result.status == PhoneResolveStatus.success) {
        setState(() {
          _telefonoController.text = result.numero;
          _telefonoTocado = true;
        });
      } else if (result.status == PhoneResolveStatus.permissionDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo leer el número de su SIM. '
                  'Ingrésalo manualmente — quedará registrado '
                  'en cada acceso que registre.',
            ),
            duration: Duration(seconds: 5),
          ),
        );
      }
      // empty / cancelled / unsupported / error → campo manual, sin ruido
    } finally {
      if (mounted) setState(() => _buscandoNumero = false);
    }
  }

  // ── Validaciones ──────────────────────────────────────────────────────────
  String? get _errorTelefono {
    if (!_telefonoTocado) return null;
    final tel = _telefonoController.text.trim();
    if (tel.isEmpty)      return 'Ingresa tu número de teléfono';
    if (tel.length != 10) return 'El teléfono debe tener 10 dígitos';
    if (!RegExp(r'^\d{10}$').hasMatch(tel)) return 'Solo números';
    return null;
  }

  String? get _errorArea {
    if (!_areaTocada) return null;
    if (_areaSeleccionada.isEmpty) return 'Selecciona tu área';
    return null;
  }

  bool get _formularioValido =>
      _telefonoController.text.trim().length == 10 &&
          _areaSeleccionada.isNotEmpty;

  // ── Enviar ────────────────────────────────────────────────────────────────
  void _onAccesoPressed() {
    setState(() { _telefonoTocado = true; _areaTocada = true; });
    if (!_formularioValido) return;

    context.read<AuthBloc>().add(LoginVigilante(
      telefono: _telefonoController.text.trim(),
      area: _areaSeleccionada,
    ));
  }

  // ── UI ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseSurface,
      appBar: AppBar(
        backgroundColor: AppColors.baseSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.headingDark),
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
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.mensaje),
              backgroundColor: AppColors.actionRed,
            ));
          } else if (state is AuthUnauthenticated && state.motivo != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.motivo!.mensajeUsuario),
              backgroundColor: AppColors.actionRed,
              duration: const Duration(seconds: 5),
            ));
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.paddingPantalla),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthHeaderWidget(
                  icono: Icons.security_rounded,
                  titulo: AppStrings.tituloVigilante,
                  subtitulo: AppStrings.subtituloVigilante,
                ),
                const SizedBox(height: AppSpacing.sm),

                _InfoSesionBanner(
                  minutosInactividad: AppConfig.minutosInactividad,
                  horasJornada: AppConfig.horasJornadaLaboral,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Campo teléfono
                TextField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() => _telefonoTocado = true),
                  decoration: InputDecoration(
                    labelText: AppStrings.campoTelefono,
                    hintText: AppStrings.hintTelefono,
                    counterText: '',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    suffixIcon: _buscandoNumero
                        ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                        : IconButton(
                      tooltip: 'Usar número de mi SIM',
                      icon: const Icon(Icons.sim_card_outlined),
                      onPressed: _pedirNumeroSIM,
                    ),
                    errorText: _errorTelefono,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Selector de área
                DropdownButtonFormField<String>(
                  value: _areaSeleccionada.isEmpty ? null : _areaSeleccionada,
                  decoration: InputDecoration(
                    labelText: AppStrings.campoArea,
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    errorText: _errorArea,
                  ),
                  hint: const Text('Selecciona tu área'),
                  items: AppConfig.areasVigilante
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _areaTocada = true;
                    _areaSeleccionada = v ?? '';
                  }),
                ),
                const SizedBox(height: AppSpacing.xl),

                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) => PrimaryButtonWidget(
                    texto: AppStrings.botonRegistrarAcceso,
                    cargando: state is AuthLoading,
                    onPressed: _onAccesoPressed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Banner informativo (sin cambios) ─────────────────────────────────────────
class _InfoSesionBanner extends StatelessWidget {
  final int minutosInactividad;
  final int horasJornada;
  const _InfoSesionBanner({
    required this.minutosInactividad,
    required this.horasJornada,
  });
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // ◄ No ocupa espacio ni se muestra nada en pantalla
  }
}