import 'package:dio/dio.dart';
import 'package:http_client/src/http_exception.dart';
import 'package:meta/meta.dart';

part 'dio_adapter.dart';

const String dataAccessServerBaseURL = "http://localhost";

abstract class HttpClient {
  String baseUrl;
  Map<String, dynamic>? defaultHeaders;

  HttpClient._internal({
    required this.baseUrl,
    this.defaultHeaders,
  });

  factory HttpClient(String baseUrl, {Map<String, dynamic>? defaultHeaders}) {
    return DioAdapter(baseUrl: baseUrl, defaultHeaders: defaultHeaders);
  }

  Future<HttpResponse> get(String path, {Map<String, dynamic>? headers});

  Future<HttpResponse> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
  });

  Future<HttpResponse> put(
    String path,
    dynamic data, {
    Map<String, dynamic>? headers,
  });

  Future<HttpResponse> patch(
      String path,
      dynamic data, {
        Map<String, dynamic>? headers,
      });

  Future<HttpResponse> delete(String path, {Map<String, dynamic>? headers});
}

class HttpResponse {
  final dynamic data;
  final int statusCode;
  final Map<String, dynamic> headers;

  HttpResponse(this.data, this.statusCode, this.headers);

  @override
  String toString() =>
      "HttpResponse:\n  data = $data,\n  status code = $statusCode,\n  headers = $headers";
}
