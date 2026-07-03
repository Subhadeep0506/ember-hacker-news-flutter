import '../../domain/models/user_profile.dart';
import '../api/auth_api_service.dart';
import '../local/settings_dao.dart';

class AuthRepository {
  final AuthApiService _apiService;
  final SettingsDao _settingsDao;

  static const _tokenKey = 'auth_token';
  static const _usernameKey = 'auth_username';

  AuthRepository(this._apiService, this._settingsDao);

  Future<AuthLoginResult> login(String username, String password) async {
    final result = await _apiService.login(username, password);
    await _settingsDao.set(_tokenKey, result.token);
    await _settingsDao.set(_usernameKey, result.username);
    return result;
  }

  Future<({String? token, String? username})> loadSavedAuth() async {
    final token = await _settingsDao.get(_tokenKey);
    final username = await _settingsDao.get(_usernameKey);
    return (token: token, username: username);
  }

  Future<void> logout() async {
    await _settingsDao.delete(_tokenKey);
    await _settingsDao.delete(_usernameKey);
  }

  Future<UserProfile> getMe({required String token}) {
    return _apiService.getMe(token: token);
  }

  Future<bool> updateMe({
    required String token,
    required Map<String, dynamic> fields,
  }) {
    return _apiService.updateMe(token: token, fields: fields);
  }
}
