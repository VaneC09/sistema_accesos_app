// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : consulta_screen.dart
// Módulo    : features/visit_request/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-28
// Versión   : 2.0.0
// Descripción: Registro de visita espontánea de consulta para vigilante — RF-014
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/primary_button_widget.dart';
import '../../bloc/consulta_bloc.dart';
import '../../data/consulta_model.dart';
import '../../data/consulta_repository.dart';

class ConsultaScreen extends StatelessWidget {
  const ConsultaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConsultaBloc(
        repository: ConsultaRepository(),
      ),
      child: const _ConsultaView(),
    );
  }
}

class _ConsultaView extends StatefulWidget {
  const _ConsultaView();

  @override
  State<_ConsultaView> createState() => _ConsultaViewState();
}

class _ConsultaViewState extends State<_ConsultaView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();

  String _lugarSeleccionado = '';

  final List<String> _lugares = [
    'División de Comunicación y Difusión',
    'Desarrollo Académico',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  void _onEnviar() {
    if (!_formKey.currentState!.validate()) return;

    if (_lugarSeleccionado.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione el lugar destino'),
          backgroundColor: AppColors.actionRed,
        ),
      );
      return;
    }

    final consulta = ConsultaRequestModel(
      nombreVisitante: _nombreController.text.trim(),
      correoVisitante: _correoController.text.trim(),
      lugarDestino: _lugarSeleccionado,
    );

    context.read<ConsultaBloc>().add(
      ConsultaSubmitted(consulta: consulta),
    );
  }

  void _limpiarFormulario() {
    _nombreController.clear();
    _correoController.clear();
    setState(() => _lugarSeleccionado = '');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConsultaBloc, ConsultaState>(
      listener: (context, state) {
        if (state is ConsultaSuccess) {
          final resultado = state.resultado;

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              backgroundColor: AppColors.baseSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              ),
              title: const Text(
                'Visita registrada',
                style: TextStyle(
                  color: AppColors.deepNavy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.successGreen,
                    size: 64,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    resultado.mensaje,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onyxGrey,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _InfoResultado(
                    etiqueta: 'Visitante',
                    valor: resultado.nombreVisitante,
                  ),
                  _InfoResultado(
                    etiqueta: 'Destino',
                    valor: resultado.lugarDestino,
                  ),
                  _InfoResultado(
                    etiqueta: 'Folio',
                    valor: resultado.folio,
                  ),
                  if (resultado.codigoQr.isNotEmpty)
                    _InfoResultado(
                      etiqueta: 'Código QR',
                      valor: resultado.codigoQr,
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'El QR podrá usarse para registrar entrada y salida.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.neutralGrey,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _limpiarFormulario();
                    context.read<ConsultaBloc>().add(ConsultaReset());
                  },
                  child: const Text(
                    'Registrar otra',
                    style: TextStyle(color: AppColors.headingDark),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryCoral,
                    foregroundColor: AppColors.baseSurface,
                  ),
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          );
        }

        if (state is ConsultaError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.mensaje),
              backgroundColor: AppColors.actionRed,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.baseSurface,
        appBar: AppBar(
          backgroundColor: AppColors.primaryCoral,
          title: const Text(
            'Visita de consulta',
            style: TextStyle(color: AppColors.baseSurface),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.baseSurface,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<ConsultaBloc, ConsultaState>(
          builder: (context, state) {
            if (state is ConsultaLoading) {
              return const LoadingWidget(
                mensaje: 'Registrando visita de consulta...',
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.paddingPantalla),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.headingSky.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMedium,
                        ),
                        border: Border.all(color: AppColors.headingSky),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.steelBlue,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Registra una visita espontánea. No requiere autorización de jefe y se generará un pase QR para entrada y salida.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.steelBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    TextFormField(
                      controller: _nombreController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del visitante',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) {
                        final nombre = value?.trim() ?? '';

                        if (nombre.isEmpty) {
                          return 'El nombre es obligatorio';
                        }

                        if (nombre.length < 5) {
                          return 'El nombre debe tener al menos 5 caracteres';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    TextFormField(
                      controller: _correoController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico del visitante',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        final correo = value?.trim() ?? '';

                        if (correo.isEmpty) {
                          return 'El correo es obligatorio';
                        }

                        final regex = RegExp(
                          r'^[\w\.-]+@[\w\.-]+\.\w+$',
                        );

                        if (!regex.hasMatch(correo)) {
                          return 'Formato de correo inválido';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    DropdownButtonFormField<String>(
                      value: _lugarSeleccionado.isEmpty
                          ? null
                          : _lugarSeleccionado,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Lugar destino',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      hint: const Text('Seleccione el destino'),
                      items: _lugares
                          .map(
                            (lugar) => DropdownMenuItem(
                          value: lugar,
                          child: Text(
                            lugar,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _lugarSeleccionado = value ?? '');
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Seleccione el lugar destino';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    PrimaryButtonWidget(
                      texto: 'Registrar visita y generar QR',
                      icono: Icons.qr_code_rounded,
                      onPressed: _onEnviar,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoResultado extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _InfoResultado({
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    if (valor.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$etiqueta: ',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.deepNavy,
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                color: AppColors.onyxGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}