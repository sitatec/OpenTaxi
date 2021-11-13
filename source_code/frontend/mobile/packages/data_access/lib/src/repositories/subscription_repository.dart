import 'package:data_access/src/repositories/base_repository.dart';
import 'package:http_client/http_client.dart';

class SubscriptionRepository extends BaseRepository{
  SubscriptionRepository(HttpClient httpClient) : super("/subscription", httpClient);
}
  