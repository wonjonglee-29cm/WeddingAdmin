import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding/data/raw/signin_raw.dart';

import 'auth_interceptor.dart';

class Api {
  static const String baseUrl = 'https://api.leewonjong.com/admin';

  static Future<Dio> getDio() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    final dio = Dio(options);

    dio.interceptors.addAll([
      AuthInterceptor(prefs),
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    ]);

    return dio;
  }

  static Future<Response> signIn(SignInRaw request) async {
    final dio = await getDio();
    return dio.post('/member/sign-in', data: request.toJson());
  }

  static Future<Response> signUp(SignInRaw request) async {
    final dio = await getDio();
    return dio.post('/member/sign-up', data: request.toJson());
  }

  static Future<Response> getAllMembers() async {
    final dio = await getDio();
    return dio.get('/member/all');
  }

  static Future<Response> getAllGreeting() async {
    final dio = await getDio();
    return dio.get('/greeting');
  }
}
