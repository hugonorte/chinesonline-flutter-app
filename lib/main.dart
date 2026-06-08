import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'firebase_options.dart';
import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Tratamento Global de Exceções do Flutter (erros de UI, layout, etc)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('\n🚨 FLUTTER ERRO GLOBAL 🚨\n${details.exceptionAsString()}\nStack: ${details.stack}\n');
  };

  // Tratamento Global de Exceções Assíncronas (Isolates, Futures não tratados)
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('\n🚨 EXCEÇÃO ASSÍNCRONA NÃO TRATADA 🚨\n$error\nStack: $stack\n');
    return true;
  };

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('pt', 'BR'), Locale('es', 'ES')],
      path: 'assets/lang', // Pode ser ajustado se o diretório for diferente
      fallbackLocale: const Locale('pt', 'BR'),
      child: const ProviderScope(
        child: ChinesOnlineApp(),
      ),
    ),
  );
}

class ChinesOnlineApp extends ConsumerWidget {
  const ChinesOnlineApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ChinesOnline',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
        textTheme: GoogleFonts.getTextTheme(
          'Vend Sans',
          Theme.of(context).textTheme,
        ).apply(bodyColor: Colors.black, displayColor: Colors.black),
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: router,
    );
  }
}
