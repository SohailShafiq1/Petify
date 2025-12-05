import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/local_storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/pets_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/profile_provider.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local storage
  final storageService = LocalStorageService();
  await storageService.init();

  runApp(PetifyApp(storageService: storageService));
}

class PetifyApp extends StatelessWidget {
  final LocalStorageService storageService;

  const PetifyApp({
    super.key,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => PetsProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(storageService),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final router = AppRouter(authProvider).router;

          return MaterialApp.router(
            title: 'PetiFy',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue.shade700,
                primary: Colors.blue.shade700,
              ),
              useMaterial3: true,
              appBarTheme: AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
