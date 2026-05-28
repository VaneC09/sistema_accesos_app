// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : visit_request_screen.dart
// Módulo    : features/visit_request/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-25
// Versión   : 1.0.0
// Descripción: Pantalla de nueva solicitud de visita — RF-013, RF-014
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/primary_button_widget.dart';
import '../../bloc/visit_request_bloc.dart';
import '../../data/visit_request_model.dart';
import '../widgets/visitante_form_widget.dart';

class VisitRequestScreen extends StatefulWidget {
  const VisitRequestScreen({super.key});

  @override
  State<VisitRequestScreen> createState() => _VisitRequestScreenState();
}

class _VisitRequestScreenState extends State<VisitRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final _lugarController = TextEditingController();
  final _motivoController = TextEditingController();

  bool _esGrupal = false;
  DateTime? _fechaVisita;
  TimeOfDay? _horaVisita;

  int _toleranciaAntes = 15;
  int _toleranciaDespues = 15;

  String _tipoVisita = 'Personal';

  // Visitante individual
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _correoController = TextEditingController();

  // Visitantes grupales
  final List<Map<String, TextEditingController>> _visitantesGrupales = [];

  // Laravel solo acepta 15 y 30
  final List<int> _tolerancias = [15, 30];

  @override
  void dispose() {
    _lugarController.dispose();
    _motivoController.dispose();

    _nombreController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();

    for (final visitante in _visitantesGrupales) {
      visitante['nombre']!.dispose();
      visitante['apellidos']!.dispose();
      visitante['correo']!.dispose();
    }

    super.dispose();
  }

  void _agregarVisitante() {
    setState(() {
      _visitantesGrupales.add({
        'nombre': TextEditingController(),
        'apellidos': TextEditingController(),
        'correo': TextEditingController(),
      });
    });
  }

  void _eliminarVisitante(int index) {
    setState(() {
      _visitantesGrupales[index]['nombre']!.dispose();
      _visitantesGrupales[index]['apellidos']!.dispose();
      _visitantesGrupales[index]['correo']!.dispose();
      _visitantesGrupales.removeAt(index);
    });
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (fecha != null) {
      setState(() => _fechaVisita = fecha);
    }
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hora != null) {
      setState(() => _horaVisita = hora);
    }
  }

  void _onEnviarSolicitud() {
    if (!_formKey.currentState!.validate()) return;

    if (_fechaVisita == null || _horaVisita == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.errorCamposIncompletos),
          backgroundColor: AppColors.actionRed,
        ),
      );
      return;
    }

    final fechaCompleta = DateTime(
      _fechaVisita!.year,
      _fechaVisita!.month,
      _fechaVisita!.day,
      _horaVisita!.hour,
      _horaVisita!.minute,
    );

    if (fechaCompleta.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La fecha y hora de visita no puede ser anterior a la actual',
          ),
          backgroundColor: AppColors.actionRed,
        ),
      );
      return;
    }

    List<VisitanteModel> visitantes = [];

    if (_esGrupal) {
      if (_visitantesGrupales.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agregue al menos un visitante al grupo'),
            backgroundColor: AppColors.actionRed,
          ),
        );
        return;
      }

      visitantes = _visitantesGrupales
          .map(
            (v) => VisitanteModel(
          nombre: v['nombre']!.text.trim(),
          apellidos: v['apellidos']!.text.trim(),
          correo: v['correo']!.text.trim(),
        ),
      )
          .toList();

      final correos = visitantes.map((v) => v.correo).toList();

      if (correos.toSet().length != correos.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.errorCorreoDuplicado),
            backgroundColor: AppColors.actionRed,
          ),
        );
        return;
      }
    } else {
      visitantes = [
        VisitanteModel(
          nombre: _nombreController.text.trim(),
          apellidos: _apellidosController.text.trim(),
          correo: _correoController.text.trim(),
        ),
      ];
    }

    final solicitud = VisitRequestModel(
      tipoVisita: _tipoVisita,
      esGrupal: _esGrupal,
      visitantes: visitantes,
      lugarDestino: _lugarController.text.trim(),
      fechaVisita: fechaCompleta,
      motivoVisita: _motivoController.text.trim(),
      toleranciaAntesMinutos: _toleranciaAntes,
      toleranciaDespuesMinutos: _toleranciaDespues,
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
              title: const Text(AppStrings.solicitudEnviada),
              content: Text(
                '${AppStrings.solicitudRegistrada}${state.folio}',
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
                  child: const Text(AppStrings.botonAceptar),
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
            AppStrings.tituloNuevaSolicitud,
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
              return const LoadingWidget(mensaje: 'Enviando solicitud...');
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.paddingPantalla),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _tipoVisita,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de visita',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Proveedor',
                          child: Text('Proveedor'),
                        ),
                        DropdownMenuItem(
                          value: 'Institucional / Negocios',
                          child: Text('Institucional / Negocios'),
                        ),
                        DropdownMenuItem(
                          value: 'Personal',
                          child: Text('Personal'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _tipoVisita = value ?? 'Personal');
                      },
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Row(
                      children: [
                        Switch(
                          value: _esGrupal,
                          activeColor: AppColors.primaryCoral,
                          onChanged: (value) {
                            setState(() {
                              _esGrupal = value;

                              if (value && _visitantesGrupales.isEmpty) {
                                _agregarVisitante();
                              }
                            });
                          },
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          AppStrings.labelVisitaGrupal,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    if (!_esGrupal) ...[
                      VisitanteFormWidget(
                        indice: 0,
                        nombreController: _nombreController,
                        apellidosController: _apellidosController,
                        correoController: _correoController,
                        mostrarEliminar: false,
                      ),
                    ],

                    if (_esGrupal) ...[
                      Text(
                        'Visitantes del grupo',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ..._visitantesGrupales.asMap().entries.map((entry) {
                        return VisitanteFormWidget(
                          indice: entry.key,
                          nombreController: entry.value['nombre']!,
                          apellidosController: entry.value['apellidos']!,
                          correoController: entry.value['correo']!,
                          onEliminar: () => _eliminarVisitante(entry.key),
                        );
                      }),
                      TextButton.icon(
                        onPressed: _agregarVisitante,
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.primaryCoral,
                        ),
                        label: const Text(
                          AppStrings.botonAgregarVisitante,
                          style: TextStyle(color: AppColors.primaryCoral),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.md),

                    TextFormField(
                      controller: _lugarController,
                      decoration: const InputDecoration(
                        labelText: AppStrings.labelLugarDestino,
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese el lugar destino';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _seleccionarFecha,
                            icon: const Icon(Icons.calendar_today_outlined),
                            label: Text(
                              _fechaVisita == null
                                  ? AppStrings.labelFecha
                                  : '${_fechaVisita!.day}/${_fechaVisita!.month}/${_fechaVisita!.year}',
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              foregroundColor: AppColors.headingDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _seleccionarHora,
                            icon: const Icon(Icons.access_time_rounded),
                            label: Text(
                              _horaVisita == null
                                  ? AppStrings.labelHora
                                  : _horaVisita!.format(context),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              foregroundColor: AppColors.headingDark,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    TextFormField(
                      controller: _motivoController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: AppStrings.labelMotivo,
                        prefixIcon: Icon(Icons.notes_rounded),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese el motivo de la visita';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Text(
                      AppStrings.labelToleranciaLlegada,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                AppStrings.labelToleranciaAntes,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.neutralGrey,
                                ),
                              ),
                              DropdownButtonFormField<int>(
                                value: _toleranciaAntes,
                                items: _tolerancias
                                    .map(
                                      (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text('$t min'),
                                  ),
                                )
                                    .toList(),
                                onChanged: (value) {
                                  setState(
                                        () => _toleranciaAntes = value ?? 15,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                AppStrings.labelToleranciaDespues,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.neutralGrey,
                                ),
                              ),
                              DropdownButtonFormField<int>(
                                value: _toleranciaDespues,
                                items: _tolerancias
                                    .map(
                                      (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text('$t min'),
                                  ),
                                )
                                    .toList(),
                                onChanged: (value) {
                                  setState(
                                        () => _toleranciaDespues = value ?? 15,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    BlocBuilder<VisitRequestBloc, VisitRequestState>(
                      builder: (context, state) {
                        return PrimaryButtonWidget(
                          texto: AppStrings.botonEnviarSolicitud,
                          cargando: state is VisitRequestLoading,
                          onPressed: _onEnviarSolicitud,
                        );
                      },
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