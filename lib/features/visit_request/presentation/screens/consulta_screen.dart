// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : consulta_screen.dart
// Módulo    : features/visit_request/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-25
// Versión   : 1.0.0
// Descripción: Solicitud de visita por consulta para vigilante — RF-014, RF-049
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/primary_button_widget.dart';
import '../../bloc/visit_request_bloc.dart';
import '../../data/visit_request_model.dart';
import '../../data/visit_request_repository.dart';

class ConsultaScreen extends StatelessWidget {
  const ConsultaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VisitRequestBloc(
        repository: VisitRequestRepository(),
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

  // RF-014: solo 2 destinos para visita de consulta
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

    final solicitud = VisitRequestModel(
      tipoVisita: 'Consulta',
      esGrupal: false,
      visitantes: [
        VisitanteModel(
          nombre: _nombreController.text.trim(),
          correo: _correoController.text.trim(),
        ),
      ],
      lugarDestino: _lugarSeleccionado,
      fechaVisita: DateTime.now(),
      motivoVisita: 'Visita espontánea de consulta',
      toleranciaAntesMinutos: 0,
      toleranciaDespuesMinutos: 30,
    );

    context.read<VisitRequestBloc>().add(
      VisitRequestSubmitted(solicitud: solicitud),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VisitRequestBloc, VisitRequestState>(
      listener: (context, state) {
        if (state is VisitRequestSuccess) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              title: const Text('Solicitud registrada'),
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
                    'El pase QR fue enviado al correo del visitante.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Folio: ${state.folio}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.deepNavy,
                    ),
                  ),
                ],
              ),
              actions: [
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
        } else if (state is VisitRequestError) {
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
        body: BlocBuilder<VisitRequestBloc, VisitRequestState>(
          builder: (context, state) {
            if (state is VisitRequestLoading) {
              return const LoadingWidget(mensaje: 'Registrando visita...');
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.paddingPantalla),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Encabezado informativo
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.headingSky.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                        border: Border.all(color: AppColors.headingSky),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppColors.steelBlue),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Registro de visita espontánea. El QR se enviará al correo del visitante.',
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

                    // Nombre del visitante
                    TextFormField(
                      controller: _nombreController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del visitante',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 5) {
                          return 'El nombre debe tener al menos 5 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Correo del visitante
                    TextFormField(
                      controller: _correoController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico del visitante',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El correo es obligatorio';
                        }
                        final regex = RegExp(r'^[\w.-]+@[\w.-]+\.\w+$');
                        if (!regex.hasMatch(value.trim())) {
                          return 'Formato de correo inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Lugar destino — RF-014: solo 2 opciones
                    DropdownButtonFormField<String>(
                      value: _lugarSeleccionado.isEmpty ? null : _lugarSeleccionado,
                      isExpanded: true,   // ← agregar esto
                      decoration: const InputDecoration(
                        labelText: 'Lugar destino',
                      ),
                      hint: const Text('Seleccione el destino'),
                      items: _lugares
                          .map((lugar) => DropdownMenuItem(
                        value: lugar,
                        child: Text(lugar),
                      ))
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
                      texto: 'Registrar visita y enviar QR',
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