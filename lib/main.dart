import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'firebase_options.dart';
import 'features/document/data/cloudinary_sync_service.dart';

void main() async {
  // Ensure Flutter engine bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase using custom credentials from firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // ProviderScope houses all active Riverpod states
    const ProviderScope(
      child: VaultMasterApp(),
    ),
  );
}

class VaultMasterApp extends ConsumerWidget {
  const VaultMasterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize global background sync engine
    ref.watch(cloudinarySyncServiceProvider);

    // Reactive binding to the GoRouter configuration provider
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'VaultMaster',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
