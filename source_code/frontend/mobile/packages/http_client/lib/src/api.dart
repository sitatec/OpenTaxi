import 'package:dio/dio.dart';
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

  Future<HttpResponse> getJson(String path, {Map<String, dynamic>? headers});

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

  Future<HttpResponse> delete(String path, {Map<String, dynamic>? headers});
}

class HttpResponse {
  final dynamic data;
  final int status;
  final Map<String, dynamic> headers;

  HttpResponse(this.data, this.status, this.headers);
}
