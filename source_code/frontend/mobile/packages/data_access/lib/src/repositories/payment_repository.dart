import 'package:data_access/src/repositories/base_repository.dart';
import 'package:http_client/http_client.dart';

class PaymentRepository extends BaseRepository{
  PaymentRepository(HttpClient httpClient) : super("/payment", httpClient);
}
