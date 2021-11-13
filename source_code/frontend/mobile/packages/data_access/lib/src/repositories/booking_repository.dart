import 'package:data_access/src/repositories/base_repository.dart';
import 'package:http_client/http_client.dart';

class BookingRepository extends BaseRepository {
  BookingRepository([HttpClient? httpClient])
      : super("/booking", httpClient: httpClient);
}
