class AuthState {
  final String? token;
  final String? username;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.token,
    this.username,
    this.isLoading = false,
    this.error,
  });

  bool get isLoggedIn => token != null;

  AuthState copyWith({
    String? token,
    String? username,
    bool? isLoading,
    String? error,
    bool clearToken = false,
    bool clearError = false,
  }) {
    return AuthState(
      token: clearToken ? null : (token ?? this.token),
      username: clearToken ? null : (username ?? this.username),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
