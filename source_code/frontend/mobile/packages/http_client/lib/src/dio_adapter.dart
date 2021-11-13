part of 'api.dart';

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
  Future<HttpResponse> get(String path, {Map<String, dynamic>? headers}) {
    return _wrapRequest(headers, (options) {
      return _dio.get(path, options: options);
    });
  }

  @override
  Future<HttpResponse> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
  }) {
    return _wrapRequest(headers, (options) {
      return _dio.post(path, data: data, options: options);
    });
  }

  @override
  Future<HttpResponse> put(
    String path,
    dynamic data, {
    Map<String, dynamic>? headers,
  }) {
    return _wrapRequest(headers, (options) {
      return _dio.post(path, data: data, options: options);
    });
  }

  @override
  Future<HttpResponse> patch(
    String path,
    dynamic data, {
    Map<String, dynamic>? headers,
  }) {
    return _wrapRequest(headers, (options) {
      return _dio.patch(path, data: data, options: options);
    });
  }

  @override
  Future<HttpResponse> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
  }) {
    return _wrapRequest(headers, (options) {
      return _dio.delete(path, data: data, options: options);
    });
  }

  Future<HttpResponse> _wrapRequest(
    Map<String, dynamic>? headers,
    Future<Response> Function(Options options) makeRequest,
  ) async {
    try {
      final options = Options(headers: headers ?? defaultHeaders);
      return (await makeRequest(options)).toHttpResponse();
    } on DioError catch (e) {
      throw e.toHttpException();
    }
  }
}

extension on Response {
  HttpResponse toHttpResponse() =>
      HttpResponse(data, statusCode ?? -1, headers.map);
}

extension on DioError {
  HttpException toHttpException() =>
      HttpException(message, response?.toHttpResponse());
}
