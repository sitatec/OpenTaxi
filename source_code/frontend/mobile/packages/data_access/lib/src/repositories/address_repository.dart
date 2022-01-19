import 'package:data_access/src/repositories/base_repository.dart';
import 'package:http_client/http_client.dart';

class AddressRepository extends BaseRepository {
  AddressRepository([HttpClient? httpClient])
      : super("/address", httpClient: httpClient);
}
