import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'multipart_file.dart';


enum HttpMethod { GET, POST, PUT, DELETE, PATCH }

class StateFlowResponse {
  final int statusCode;
  final String body;
  final String reasonPhrase;

  StateFlowResponse(this.statusCode, this.body, this.reasonPhrase);
}

class StateFlowClient {
  final String baseUrl;
  final Map<String, String> defaultHeaders;
  final Duration timeout;

  StateFlowClient({
    required this.baseUrl,
    this.defaultHeaders = const {},
    this.timeout = const Duration(seconds: 30),
  });

  Future<HttpClientResponse> _sendRequest(
    String path,
    HttpMethod method, {
    Map<String, String>? headers,
    dynamic body,
    List<MultipartFile>? files,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final httpClient = HttpClient()..connectionTimeout = timeout;

    try {
      late HttpClientRequest request;

      switch (method) {
        case HttpMethod.GET:
          request = await httpClient.getUrl(uri);
          break;
        case HttpMethod.POST:
          request = await httpClient.postUrl(uri);
          break;
        case HttpMethod.PUT:
          request = await httpClient.putUrl(uri);
          break;
        case HttpMethod.DELETE:
          request = await httpClient.deleteUrl(uri);
          break;
        case HttpMethod.PATCH:
          request = await httpClient.patchUrl(uri);
          break;
      }

      defaultHeaders.forEach((key, value) {
        request.headers.set(key, value);
      });
      if (headers != null) {
        headers.forEach((key, value) {
          request.headers.set(key, value);
        });
      }

      if (files != null && files.isNotEmpty) {
        final boundary = _generateBoundary();
        request.headers
            .set('content-type', 'multipart/form-data; boundary=$boundary');
        await _writeMultipartBody(request, body, files, boundary);
      } else if (body != null) {
        request.headers.set('content-type', 'application/json');
        request.add(utf8.encode(json.encode(body)));
      }

      return await request.close();
    } catch (e) {
      httpClient.close();
      rethrow;
    }
  }

  Future<StateFlowResponse> sendRequest(
    String path,
    HttpMethod method, {
    Map<String, String>? headers,
    dynamic body,
    List<MultipartFile>? files,
  }) async {
    try {
      final response = await _sendRequest(path, method,
          headers: headers, body: body, files: files);
      final responseBody = await response.transform(utf8.decoder).join();

      return StateFlowResponse(
        response.statusCode,
        responseBody,
        response.reasonPhrase,
      );
    } catch (e) {
      return StateFlowResponse(
        500,
        'An error occurred: $e',
        'Internal Server Error',
      );
    }
  }

  String _generateBoundary() => '----${DateTime.now().millisecondsSinceEpoch}';

  Future<void> _writeMultipartBody(
    HttpClientRequest request,
    Map<String, dynamic>? fields,
    List<MultipartFile> files,
    String boundary,
  ) async {
    fields?.forEach((key, value) {
      request.write('--$boundary\r\n');
      request.write('Content-Disposition: form-data; name="$key"\r\n\r\n');
      request.write('$value\r\n');
    });

    for (final file in files) {
      request.write('--$boundary\r\n');
      request.write(
          'Content-Disposition: form-data; name="${file.field}"; filename="${file.filename}"\r\n');
      request.write('Content-Type: ${file.contentType}\r\n\r\n');
      await request.addStream(file.stream);
      request.write('\r\n');
    }

    request.write('--$boundary--\r\n');
    await request.close();
  }
}
