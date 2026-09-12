import 'package:flutter_test/flutter_test.dart';
import 'package:central_boxing/main.dart';

void main() {
  testWidgets('App smoke', (t) async {
    await t.pumpWidget(const App());
    expect(find.byType(App), findsOneWidget);
  });
}
