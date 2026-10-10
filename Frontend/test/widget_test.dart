import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rumbo_app/main.dart';
import 'package:rumbo_app/data/services/api_service.dart';
import 'package:rumbo_app/viewmodels/auth_viewmodel.dart';
import 'package:rumbo_app/viewmodels/courses_viewmodel.dart';
import 'package:rumbo_app/viewmodels/riesgo_viewmodel.dart';

void main() {
  testWidgets('RumboApp smoke test - renders Login screen and title', (WidgetTester tester) async {
    final apiService = ApiService();
    final authVm = AuthViewModel(apiService: apiService);
    final coursesVm = CoursesViewModel(apiService: apiService);
    final riesgoVm = RiesgoViewModel(apiService: apiService);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authVm),
          ChangeNotifierProvider.value(value: coursesVm),
          ChangeNotifierProvider.value(value: riesgoVm),
        ],
        child: RumboApp(authVm: authVm),
      ),
    );

    // Verify Rumbo brand and Ingresar button exist
    expect(find.text('Rumbo'), findsOneWidget);
    expect(find.text('Ingresar'), findsOneWidget);
  });
}
