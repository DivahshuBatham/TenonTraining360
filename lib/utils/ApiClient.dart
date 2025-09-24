import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../environment/Environment.dart'; // <-- your AppConfig class

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl, // ✅ dynamic from AppConfig
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Accept": "application/json",
      },
    ),
  )..interceptors.add(LoggingInterceptor());
}

/// Interceptor for logging API activity
class LoggingInterceptor extends Interceptor {
  bool get _isDebugEnv =>
      AppConfig.environment == Environment.dev ||
          AppConfig.environment == Environment.staging;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final log = """
➡️ REQUEST[${options.method}] => PATH: ${options.uri}
Headers: ${options.headers}
Body: ${options.data}
""";

    if (_isDebugEnv) print(log); // ✅ Console log only in dev/staging
    FirebaseCrashlytics.instance.log(log); // ✅ Always log to Crashlytics

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final log = """
✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.uri}
Response Data: ${response.data}
""";

    if (_isDebugEnv) print(log);
    FirebaseCrashlytics.instance.log(log);

    super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    final log = """
❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.uri}
Error: ${err.message}
Response: ${err.response?.data}
""";

    if (_isDebugEnv) print(log);
    FirebaseCrashlytics.instance.log(log);

    FirebaseCrashlytics.instance.recordError(
      err,
      err.stackTrace,
      reason:
      "API ERROR[${err.response?.statusCode}] ${err.requestOptions.path}",
      fatal: false,
    );

    super.onError(err, handler);
  }
}
