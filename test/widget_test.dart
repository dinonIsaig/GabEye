import 'package:flutter_test/flutter_test.dart';
import 'package:gabeye/main.dart';

void main() {
  testWidgets('GabEye app instantiates successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const GabEye());
    expect(find.byType(GabEye), findsOneWidget);
  });
}
