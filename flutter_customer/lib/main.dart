import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/router/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  // FIX Phase 67: Global Error Reporting
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    _reportError(details.exceptionAsString(), details.stack.toString());
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    _reportError(error.toString(), stack.toString());
    return true;
  };

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: String.fromEnvironment('FIREBASE_API_KEY', defaultValue: ''),
        appId: String.fromEnvironment('FIREBASE_APP_ID', defaultValue: ''),
        messagingSenderId:
            String.fromEnvironment('FIREBASE_SENDER_ID', defaultValue: ''),
        projectId:
            String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: ''),
      ),
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  await NotificationService.initialize();

  runApp(
    const ProviderScope(
      child: MarketplaceApp(),
    ),
  );
}

// FIX Phase 67: Helper for reporting errors to backend
void _reportError(String message, String stack) async {
  debugPrint('🚨 Reporting Crash: $message');
  try {
    final baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:5001';
    final url = Uri.parse('$baseUrl/api/v1/utils/report-error');
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 5);
    final request = await client.postUrl(url);
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode({
      'type': 'flutter_crash',
      'app_name': 'customer',
      'error_message': message,
      'stack_trace': stack,
    }));
    final response = await request.close().timeout(const Duration(seconds: 5));
    await response.drain();
    client.close();
  } catch (e) {
    debugPrint('Failed to report error: $e');
  }
}

class MarketplaceApp extends ConsumerWidget {
  const MarketplaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'كيف نخدمك',
      debugShowCheckedModeBanner: false,

      // الثيم
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // اللغات والاتجاه
      locale: const Locale('ar', 'SD'),
      supportedLocales: const [
        Locale('ar', 'SD'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // التوجيه
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
    );
  }
}
