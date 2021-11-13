import 'package:data_access/src/repositories/base_repository.dart';
import 'package:http_client/http_client.dart';

class AccountRepository extends BaseRepository{
  AccountRepository(HttpClient httpClient) : super("/account", httpClient);
}
