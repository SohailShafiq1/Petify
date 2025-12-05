import 'package:flutter_test/flutter_test.dart';
import 'package:petify/main.dart';
import 'package:petify/services/local_storage_service.dart';

void main() {
  testWidgets('PetiFy app smoke test', (WidgetTester tester) async {
    // Initialize storage service
    final storageService = LocalStorageService();
    await storageService.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(PetifyApp(storageService: storageService));

    // Verify that login screen is shown
    expect(find.text('Welcome to PetiFy'), findsOneWidget);
    expect(find.text('Login to continue'), findsOneWidget);
  });
}
