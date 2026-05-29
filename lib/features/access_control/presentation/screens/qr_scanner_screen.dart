// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : qr_scanner_screen.dart
// Módulo    : features/access_control/presentation/screens
// Autor     : Omega Company
// Fecha     : 2026-05-28
// Versión   : 1.1.0
// Descripción: Pantalla de escaneo QR para vigilante — RF-022
//              Fix: teléfono y área leídos de SecureStorage, no de AuthState
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/loading_widget.dart';
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
  final _storage = const FlutterSecureStorage();

  MobileScannerController? _scannerController;
  bool _escaneando = true;

  // Teléfono y área del vigilante leídos de SecureStorage al iniciar
  String _telefono = '';
  String _area     = '';
  bool _cargandoDatos = true;
  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
    _cargarDatosVigilante();
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  // ── Carga teléfono y área desde almacenamiento seguro ─────────────────────
  Future<void> _cargarDatosVigilante() async {
    final tel  = await _storage.read(key: AppConfig.claveTelefonoVigilante) ?? '';
    final area = await _storage.read(key: AppConfig.claveAreaVigilante)     ?? '';
    if (mounted) {
      setState(() {
        _telefono = tel;
        _area     = area;
        _cargandoDatos  = false;
      });
    }
  }

  // ── Escaneo por cámara ────────────────────────────────────────────────────
  void _onQrDetectado(BarcodeCapture capture) {
    if (!_escaneando) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    // Validar que tengamos teléfono antes de enviar
    if (_telefono.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontraron datos del vigilante. Vuelve a identificarte.'),
          backgroundColor: AppColors.actionRed,
        ),
      );
      return;
    }

    setState(() => _escaneando = false);
    _scannerController?.stop();

    context.read<AccessControlBloc>().add(
      EscanearQr(
        codigoQr: barcode!.rawValue!,
        telefono: _telefono,
        area:     _area,
      ),
    );
  }

  // ── Ingreso manual ────────────────────────────────────────────────────────
  Future<void> _onRegistroManual() async {
    final codigo = await ManualCodeDialog.mostrar(context);
    if (!mounted) return;
    if (codigo == null) return;

    if (_telefono.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontraron datos del vigilante. Vuelve a identificarte.'),
          backgroundColor: AppColors.actionRed,
        ),
      );
      return;
    }

    setState(() => _escaneando = false);
    _scannerController?.stop();

    if (!mounted) return;
    context.read<AccessControlBloc>().add(
      RegistroManual(
        codigoNumerico: codigo,
        telefono:       _telefono,
        area:           _area,
      ),
    );
  }

  // ── Resetear para nuevo escaneo ───────────────────────────────────────────
  void _onNuevoEscaneo() {
    context.read<AccessControlBloc>().add(ResetAcceso());
    setState(() => _escaneando = true);
    _scannerController?.start();
  }

  // ── UI ────────────────────────────────────────────────────────────────────
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
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.baseSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<AccessControlBloc, AccessControlState>(
        builder: (context, state) {

          if (state is AccessControlLoading) {
            return const LoadingWidget(mensaje: 'Validando acceso...');
          }

          if (state is QrEscaneadoSuccess) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.paddingPantalla),
              child: QrResultWidget(
                resultado: state.resultado,
                onNuevoEscaneo: _onNuevoEscaneo,
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
                      onPressed: _onNuevoEscaneo,
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
          if (_cargandoDatos) {
            return const LoadingWidget(mensaje: 'Cargando datos del vigilante...');
          }
          // ── Vista principal: cámara + botón manual ────────────────────────
          return Column(
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: _onQrDetectado,   // ← ya no pasa context
                    ),
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
                        onPressed: _onRegistroManual,  // ← ya no pasa context
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