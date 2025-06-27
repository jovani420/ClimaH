import 'package:app_clima/provider/theme_provider.dart';
import 'package:app_clima/theme/theme.dart';
import 'package:app_clima/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNofierProvider);

    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
