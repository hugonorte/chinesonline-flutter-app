import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode, debugPrint;

String _getBaseUrl() {
  // Permite injetar a URL via linha de comando no debug (ex: --dart-define=API_URL=https://...)
  const envUrl = String.fromEnvironment('API_URL');
  if (envUrl.isNotEmpty) return envUrl;

  // Em Produção, usa obrigatoriamente o Cloud Run
  if (kReleaseMode) {
    return 'https://chinesonline-go-api-80060965106.us-east1.run.app/api/v1';
  }

  // Em Desenvolvimento (fallback local)
  if (kIsWeb) return 'http://localhost:8080/api/v1';
  if (Platform.isAndroid) return 'http://10.0.2.2:8080/api/v1'; // Emulador Android
  return 'http://localhost:8080/api/v1';
}

final Dio apiClient = Dio(
  BaseOptions(
    baseUrl: _getBaseUrl(),
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ),
)..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final token = await user.getIdToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }

        try {
          final appCheckToken = await FirebaseAppCheck.instance.getToken();
          if (appCheckToken != null) {
            options.headers['X-Firebase-AppCheck'] = appCheckToken;
          }
        } catch (e) {
          debugPrint('⚠️ Erro ao obter token do AppCheck: $e');
        }

        return handler.next(options);
      },
    ),
  )..interceptors.add(
    LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
    ),
  );
