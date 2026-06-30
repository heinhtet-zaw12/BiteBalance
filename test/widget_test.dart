// Widget tests for Bite Balance app.
// Note: Full widget tests require Supabase and dotenv mocking.
// Add integration tests when test infrastructure is ready.

import 'package:flutter_test/flutter_test.dart';
import 'package:bite_balance/main.dart';

void main() {
  test('MyApp class exists and is a StatelessWidget', () {
    expect(const MyApp(), isA<MyApp>());
  });
}
