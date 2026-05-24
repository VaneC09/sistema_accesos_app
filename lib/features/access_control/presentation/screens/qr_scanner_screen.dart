// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : qr_scanner_screen.dart
// Módulo    : features/access_control/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Pantalla de escaneo QR para vigilante — RF-022
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../bloc/access_control_bloc.dart';
import '../../data/access_repository.dart';
import '../dialogs/manual_code_dialog.dart';
import '../widgets/qr_result_widget.dart';

class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AccessControlBloc(
        repository: AccessRepository(),
      ),
      child: const _QrScannerView(),
    );
  }
}

class _QrScannerView extends StatefulWidget {
  const _QrScannerView();

  @override
  State<_QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<_QrScannerView> {
  MobileScannerController? _scannerController;
  bool _escaneando = true;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  String _obtenerTelefono(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.nombre;
    }
    return '';
  }

  String _obtenerArea(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.nombre;
    }
    return '';
  }

  void _onQrDetectado(BuildContext context, BarcodeCapture capture) {
    if (!_escaneando) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    setState(() => _escaneando = false);
    _scannerController?.stop();

    context.read<AccessControlBloc>().add(
      EscanearQr(
        codigoQr: barcode!.rawValue!,
        telefono: _obtenerTelefono(context),
        area: _obtenerArea(context),
      ),
    );
  }

  Future<void> _onRegistroManual(BuildContext context) async {
    final codigo = await ManualCodeDialog.mostrar(context);
    if (codigo != null && context.mounted) {
      setState(() => _escaneando = false);
      _scannerController?.stop();

      context.read<AccessControlBloc>().add(
        RegistroManual(
          codigoNumerico: codigo,
          telefono: _obtenerTelefono(context),
          area: _obtenerArea(context),
        ),
      );
    }
  }

  void _onNuevoEscaneo(BuildContext context) {
    context.read<AccessControlBloc>().add(ResetAcceso());
    setState(() => _escaneando = true);
    _scannerController?.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseSurface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryCoral,
        title: const Text(
          AppStrings.tituloEscanerQr,
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
      body: BlocBuilder<AccessControlBloc, AccessControlState>(
        builder: (context, state) {
          if (state is AccessControlLoading) {
            return const LoadingWidget(mensaje: 'Validando QR...');
          }

          if (state is QrEscaneadoSuccess) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.paddingPantalla),
              child: QrResultWidget(
                resultado: state.resultado,
                onNuevoEscaneo: () => _onNuevoEscaneo(context),
                onExtenderTiempo: state.resultado.llegaTarde
                    ? () {}
                    : null,
              ),
            );
          }

          if (state is AccessControlError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.paddingPantalla),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.actionRed,
                      size: 72,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      state.mensaje,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.actionRed,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextButton.icon(
                      onPressed: () => _onNuevoEscaneo(context),
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.headingDark,
                      ),
                      label: const Text(
                        'Intentar nuevamente',
                        style: TextStyle(color: AppColors.headingDark),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Vista de escaneo
          return Column(
            children: [
              // Área del escáner
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: (capture) =>
                          _onQrDetectado(context, capture),
                    ),
                    // Marco de escaneo
                    Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primaryCoral,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Instrucciones y botón manual
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.paddingPantalla),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Apunta la cámara al código QR del visitante',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.neutralGrey,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextButton.icon(
                        onPressed: () => _onRegistroManual(context),
                        icon: const Icon(
                          Icons.keyboard_rounded,
                          color: AppColors.headingDark,
                        ),
                        label: const Text(
                          'Ingresar código manualmente',
                          style: TextStyle(color: AppColors.headingDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}