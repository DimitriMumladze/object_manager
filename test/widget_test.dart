import 'package:flutter_test/flutter_test.dart';
import 'package:object_manager/app.dart';
import 'package:object_manager/core/services/auth_service.dart';
import 'package:object_manager/core/theme/theme_cubit.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    final authService = AuthService();
    final themeCubit = ThemeCubit();
    await tester.pumpWidget(ObjectManagerApp(authService: authService, themeCubit: themeCubit));
    expect(find.text('ObjectManager'), findsOneWidget);
  });
}
