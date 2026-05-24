import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_accesos_app/main.dart';

void main() {
  testWidgets('App inicia correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const SistemaAccesosApp());
  });
}