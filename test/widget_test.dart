import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zrex_company_project/main.dart';

void main() {
  testWidgets('App renders home feed', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: InstaFeedApp()));
    await tester.pump(const Duration(milliseconds: 1600));
    expect(find.text('Instagram'), findsOneWidget);
  });
}
