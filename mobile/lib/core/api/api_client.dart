
import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_endpoints.dart';

class ApiClient {
  ApiClient._();

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,

      // Allow more time for the deployed backend.
      connectTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),

      headers: {
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Retrieve stored JWT token.
          final token = await TokenStorage.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] =
                'Bearer $token';
          }

          handler.next(options);
        },

        onError: (error, handler) {
          // Log errors during development.
          assert(() {
            print(
              'API Error: '
              '${error.requestOptions.method} '
              '${error.requestOptions.uri} - '
              '${error.response?.statusCode ?? error.type}',
            );
            return true;
          }());

          handler.next(error);
        },
      ),
    );
}
