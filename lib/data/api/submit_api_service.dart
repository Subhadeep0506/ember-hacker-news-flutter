import 'api_client.dart';

class SubmitApiService {
  final ApiClient _client;

  SubmitApiService(this._client);

  Future<bool> submitPost({
    required String title,
    String? url,
    String? text,
    required String token,
  }) async {
    final body = <String, dynamic>{'title': title};
    if (url != null && url.isNotEmpty) body['url'] = url;
    if (text != null && text.isNotEmpty) body['text'] = text;

    final json = await _client.post(
      '/write/submit',
      body: body,
      token: token,
    );
    return json['ok'] as bool;
  }
}
