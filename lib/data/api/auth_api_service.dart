import 'api_client.dart';

class AuthLoginResult {
  final String token;
  final String username;

  const AuthLoginResult({required this.token, required this.username});
}

class AuthApiService {
  final ApiClient _client;

  AuthApiService(this._client);

  Future<AuthLoginResult> login(String username, String password) async {
    final json = await _client.post(
      '/auth/login',
      body: {'username': username, 'password': password},
    );
    return AuthLoginResult(
      token: json['token'] as String,
      username: json['username'] as String,
    );
  }
}
