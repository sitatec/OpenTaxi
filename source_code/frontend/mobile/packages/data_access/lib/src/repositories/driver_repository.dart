import 'package:data_access/src/repositories/base_repository.dart';
import 'package:data_access/src/repositories/user_base_repository.dart';
import 'package:http_client/http_client.dart';

class DriverRepository extends UserBaseRepository {
  DriverRepository([HttpClient? httpClient])
      : super("/driver", httpClient: httpClient);
}
