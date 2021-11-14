part of 'api.dart';

@internal
class TripRoomImplementation extends TripRoom {
  final DatabaseReference _firebaseDb;
  final String _driverId;
  String _riderId = "";
  String? _viewerId;
  StreamSubscription<Event>? _roomStreamsSubscription;
  StreamSubscription<Location>? _locationSourceStreamSubscription;
  StreamSubscription<double>? _speedSourceStreamSubscription;

  final _locationStreamController = StreamController<Location>();
  final _speedStreamController = StreamController<double>();
  final _tripEventStreamController = StreamController<TripEvent>();

  TripRoomImplementation(
    String id, {
    DatabaseReference? firebaseDb,
    Stream<Location>? locationSourceStream,
    Stream<double>? speedSourceStream,
  })  : _firebaseDb = firebaseDb ??
            FirebaseDatabase.instance.reference().child("trip_rooms"),
        _driverId = id,
        // Currently the room id is the driver id.
        super._internal(id, locationSourceStream, speedSourceStream) {
    _firebaseDb
        .child("$id/riderId")
        .once()
        .then((snapshot) => _riderId = snapshot.value);
    _listenToSourceStreams();
  }

  void _listenToSourceStreams() {
    _locationSourceStreamSubscription =
        _locationSourceStream?.listen((location) {
      _firebaseDb.child("$id/location").set(location.toString());
    });
    _speedSourceStreamSubscription = _speedSourceStream?.listen((speed) {
      _firebaseDb.child("$id/speed").set(speed);
    });
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
    await _roomStreamsSubscription?.cancel();
    await _speedSourceStreamSubscription?.cancel();
    await _locationSourceStreamSubscription?.cancel();
    await _tripEventStreamController.close();
    await _speedStreamController.close();
    await _locationStreamController.close();
  }
}
