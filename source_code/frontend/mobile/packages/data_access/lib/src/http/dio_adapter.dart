part of "http_client.dart";

@internal
class DioAdapter extends HttpClient {
  late Dio _dio;

  DioAdapter({
    String baseUrl = dataAccessServerBaseURL,
    Map<String, dynamic>? defaultHeaders,
  }) : super._internal(baseUrl: baseUrl, defaultHeaders: defaultHeaders) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: defaultHeaders,
      responseType: ResponseType.plain,
    ));
  }

  @visibleForTesting
  DioAdapter.testConstructor(this._dio) : super._internal(baseUrl: "");

  @override
  Future<HttpResponse> get(String path, {Map<String, dynamic>? headers}) async {
    final options = Options(headers: headers ?? defaultHeaders);
    final response = await _dio.get(path, options: options);
    return _toHttpResponse(response);
  }

  @override
  Future<HttpResponse> getJson(String path, {Map<String, dynamic>? headers}) async {
    final options = Options(responseType: ResponseType.json, headers: headers ?? defaultHeaders);
    final response = await _dio.get(path, options: options);
    return _toHttpResponse(response);
  }

  @override
  Future<HttpResponse> post(String path, dynamic data, {Map<String, dynamic>? headers}) async {
    final options = Options(headers: headers ?? defaultHeaders);
    final response = await _dio.post(path, data: data, options: options);
    return _toHttpResponse(response);
  }

  @override
  Future<HttpResponse> put(String path, dynamic data, {Map<String, dynamic>? headers}) async {
    final options = Options(headers: headers ?? defaultHeaders);
    final response = await _dio.post(path, data: data, options: options);
    return _toHttpResponse(response);
  }

  @override
  Future<HttpResponse> delete(String path, {dynamic data, Map<String, dynamic>? headers}) async {
    final options = Options(headers: headers ?? defaultHeaders);
    final response = await _dio.delete(path, data: data, options: options);
    return _toHttpResponse(response);
  }

  HttpResponse _toHttpResponse(Response dioResponse) =>
      HttpResponse(
        dioResponse.data,
        dioResponse.statusCode ?? -1,
        dioResponse.headers.map,
      );
}
