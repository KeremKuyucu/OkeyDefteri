import 'package:flutter_test/flutter_test.dart';

import 'package:okey_defteri/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const OkeyDefteriApp());
    expect(find.text('Okey 101'), findsOneWidget);
  });
}
