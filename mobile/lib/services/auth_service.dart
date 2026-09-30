import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/user.dart';

class AuthResult {
  final String token;
  final User user;

  const AuthResult({
    required this.token,
    required this.user,
  });
}

class AuthService {
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.dio.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data;

    return AuthResult(
      token: data['token'],
      user: User.fromJson(data['user']),
    );
  }
}