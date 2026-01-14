import 'package:flutter_test/flutter_test.dart';

import 'package:saveme_project/main.dart';

void main() {
  testWidgets('App shows Welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('SaveMe'), findsOneWidget);
    expect(find.text('Save smarter, one day at a time'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);
  });
}
