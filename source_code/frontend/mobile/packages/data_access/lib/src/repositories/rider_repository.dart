import 'package:http_client/http_client.dart';

import 'user_base_repository.dart';

class RiderRepository extends UserBaseRepository {
  RiderRepository([HttpClient? httpClient])
      : super("/rider", httpClient: httpClient);
}
