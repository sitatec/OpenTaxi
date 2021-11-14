part of 'api.dart';

@internal
class TripRoomImplementation extends TripRoom {
  final DatabaseReference _firebaseDb;
  final String _driverId;
  String _riderId = "";
  String? _viewerId;
  StreamSubscription<Event>? _roomStreamsSubscription;

  final _locationStreamController = StreamController<Location>();
  final _speedStreamController = StreamController<double>();
  final _tripEventStreamController = StreamController<TripEvent>();

  TripRoomImplementation(String id, {DatabaseReference? firebaseDb})
      : _firebaseDb = firebaseDb ??
            FirebaseDatabase.instance.reference().child("trip_rooms"),
        _driverId = id,
        // Currently the room id is the driver id.
        super._internal(id) {
    _firebaseDb
        .child("$id/riderId")
        .once()
        .then((snapshot) => _riderId = snapshot.value);
  }

  @override
  String get driverId => _driverId;

  @override
  String get riderId => _riderId;

  @override
  String? get viewerId => _viewerId;

  @override
  Stream<Location> get locationStream => _locationStreamController.stream;

  @override
  Stream<double> get speedStream => _speedStreamController.stream;

  @override
  Stream<TripEvent> get tripEventsStream => _tripEventStreamController.stream;

  @override
  void join() {
    _roomStreamsSubscription =
        _firebaseDb.child(id).onChildChanged.listen((event) {
      final nodeKey = event.snapshot.key;
      final nodeValue = event.snapshot.value;
      switch (nodeKey) {
        case "location":
          _locationStreamController.sink.add(Location.fromString(nodeValue));
          break;
        case "speed":
          _speedStreamController.sink.add(nodeValue);
          break;
        case "viewerId":
          _viewerId = nodeValue;
          _tripEventStreamController.sink.add(TripEvent.viewerJoined);
      }
    });
    _tripEventStreamController.sink.add(TripEvent.joined);
  }

  @override
  Future<void> leave() async {
    await _roomStreamsSubscription!.cancel();
    await _tripEventStreamController.close();
    await _speedStreamController.close();
    await _locationStreamController.close();
  }
}
