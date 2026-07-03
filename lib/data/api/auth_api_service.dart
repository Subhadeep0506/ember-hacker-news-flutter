import '../../domain/models/user_profile.dart';
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

  Future<UserProfile> getMe({required String token}) async {
    final json = await _client.get('/auth/me', token: token);
    return UserProfile.fromJson(json);
  }

  Future<bool> updateMe({
    required String token,
    required Map<String, dynamic> fields,
  }) async {
    final json = await _client.patch('/auth/me', body: fields, token: token);
    return json['ok'] as bool;
  }
}
