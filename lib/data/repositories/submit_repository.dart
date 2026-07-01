import '../api/submit_api_service.dart';

class SubmitRepository {
  final SubmitApiService _apiService;

  SubmitRepository(this._apiService);

  Future<bool> submitPost({
    required String title,
    String? url,
    String? text,
    required String token,
  }) {
    return _apiService.submitPost(
      title: title,
      url: url,
      text: text,
      token: token,
    );
  }
}
