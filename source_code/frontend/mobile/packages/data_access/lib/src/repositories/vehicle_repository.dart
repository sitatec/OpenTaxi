import 'package:data_access/src/repositories/base_repository.dart';
import 'package:http_client/http_client.dart';

class VehicleRepository extends BaseRepository {
  VehicleRepository([HttpClient? httpClient])
      : super("/vehicle", httpClient: httpClient);
}
