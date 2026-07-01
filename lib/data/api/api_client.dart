import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;

  ApiClient({
    this.baseUrl = 'https://hacker-news-expressjs.onrender.com',
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParams,
    String? token,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: queryParams);
    log('GET $uri', name: 'ApiClient');

    final headers = _buildHeaders(token: token);
    final response = await _httpClient.get(uri, headers: headers);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    log('POST $uri', name: 'ApiClient');

    final headers = _buildHeaders(token: token);
    final response = await _httpClient.post(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );

    return _handleResponse(response);
  }

  Map<String, String> _buildHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    throw ApiException(
      statusCode: response.statusCode,
      error: body['error'] as String? ?? 'Unknown error',
      message: body['message'] as String?,
    );
  }
}
