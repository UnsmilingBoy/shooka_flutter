import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

class ConnectionErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if it's a connection/network error
    bool isConnectionError = false;
    String errorMessage = '';

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        isConnectionError = true;
        errorMessage = 'زمان اتصال به سرور تمام شد';
        break;
      case DioExceptionType.sendTimeout:
        isConnectionError = true;
        errorMessage = 'زمان ارسال درخواست تمام شد';
        break;
      case DioExceptionType.receiveTimeout:
        isConnectionError = true;
        errorMessage = 'زمان دریافت پاسخ تمام شد';
        break;
      case DioExceptionType.connectionError:
        isConnectionError = true;
        errorMessage =
            'خطا در اتصال به سرور. لطفا اتصال اینترنت خود را بررسی کنید';
        break;
      case DioExceptionType.badResponse:
        // Only show for server errors (500+)
        if (err.response?.statusCode != null &&
            err.response!.statusCode! >= 500) {
          isConnectionError = true;
          errorMessage = 'خطای سرور. لطفا بعدا تلاش کنید';
        }
        break;
      case DioExceptionType.unknown:
        // Usually network issues
        isConnectionError = true;
        errorMessage = 'خطا در اتصال. لطفا اتصال اینترنت خود را بررسی کنید';
        break;
      default:
        break;
    }

    // Show error dialog if it's a connection error
    if (isConnectionError) {
      log('Connection error detected: ${err.type} - $errorMessage');

      // Show toast notification
      flatErrorToast(
        title: errorMessage,
        description: 'لطفا اتصال اینترنت خود را بررسی کنید',
      );
    }

    // Always forward the error
    handler.next(err);
  }
}
