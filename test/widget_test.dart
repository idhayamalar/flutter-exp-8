import 'package:employee_information_management/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Employee app loads with title', (WidgetTester tester) async {
    await tester.pumpWidget(const EmployeeInfoApp());

    expect(find.text('Employee Information Management'), findsOneWidget);
    expect(find.text('Save Employee Details'), findsOneWidget);
  });
}
