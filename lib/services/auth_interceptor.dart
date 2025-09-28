import 'package:dio/dio.dart';
import 'auth_service.dart';

class AuthInterceptor extends Interceptor {
  final AuthService auth;

  AuthInterceptor(this.auth);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await auth.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;
    final reqOptions = err.requestOptions;

    // If 401 and we haven't retried yet, attempt refresh -> retry original
    if (status == 401 && reqOptions.extra['retried'] != true) {
      final ok = await auth.tryRefreshToken();
      if (!ok) {
        // refresh failed -> let UI handle sign out
        return handler.next(err);
      }

      // we have a new access token now
      final newToken = await auth.getAccessToken();
      if (newToken == null) return handler.next(err);

      // mark request so we don't loop
      reqOptions.extra['retried'] = true;
      reqOptions.headers['Authorization'] = 'Bearer $newToken';

      try {
        // retry the original request
        final response = await auth.dio.fetch(reqOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    // otherwise forward error
    handler.next(err);
  }
}
