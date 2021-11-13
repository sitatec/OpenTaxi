import 'package:http_client/http_client.dart';

class HttpException implements Exception {
  final String message;
  final HttpResponse? response;

  HttpException(this.message, this.response);

  @override
  String toString() => "HttpException: $message. \n Response = $response.";
}
