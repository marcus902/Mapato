import 'package:flutter_test/flutter_test.dart';
import 'package:mapato/main.dart';

void main() {
  testWidgets('Mapato app boots', (WidgetTester tester) async {
    await tester.pumpWidget(const MapatoApp());
    expect(find.text('Mapato'), findsWidgets);
  });
}
