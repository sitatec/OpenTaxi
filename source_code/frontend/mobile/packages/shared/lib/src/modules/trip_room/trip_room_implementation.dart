part of 'api.dart';

@internal
class TripRoomImplementation extends TripRoom {
  final DatabaseReference _firebaseDb;
  final String _driverId;
  bool _joined = false;
  bool _watching = false;
  String _riderId = "";
  String? _viewerId;
  StreamSubscription<Event>? _roomStreamsSubscription;
  StreamSubscription<Coordinates>? _locationSourceStreamSubscription;

  final _locationStreamController = StreamController<Coordinates>();
  final _speedStreamController = StreamController<double>();
  final _tripEventStreamController = StreamController<TripEvent>();
  late Sink<TripEvent> _tripEventSink;

  TripRoomImplementation(
    String id, {
    DatabaseReference? firebaseDb,
    Stream<Coordinates>? locationSourceStream,
  })  : _firebaseDb = firebaseDb ??
            FirebaseDatabase.instance.reference().child("trip_rooms/$id"),
        _driverId = id,
        // Currently the room id is the driver id.
        super._internal(id, locationSourceStream) {
    _tripEventSink = _tripEventStreamController.sink;
    _firebaseDb
        .child("riderId")
        .once()
        .then((snapshot) => _riderId = snapshot.value);
    _listenToSourceStreams();
  }

  void _listenToSourceStreams() {
    _locationSourceStreamSubscription =
        _locationSourceStream?.listen((location) {
      _firebaseDb.child("location").set(location.toString());
    });
  }

  @override
  String get driverId => _driverId;

  @override
  String get riderId => _riderId;

  @override
  String? get viewerId => _viewerId;

  @override
  Stream<Coordinates> get locationStream => _locationStreamController.stream;

  @override
  Stream<TripEvent> get tripEventsStream => _tripEventStreamController.stream;

  @override
  void join() {
    if (_joined) {
      return _tripEventSink.add(TripEvent.cantJoinTwice);
    }
    _roomStreamsSubscription =
        _firebaseDb.child(id).onChildChanged.listen((event) {
      final nodeKey = event.snapshot.key;
      final nodeValue = event.snapshot.value;
      switch (nodeKey) {
        case "location":
          _locationStreamController.sink.add(Coordinates.fromMap(nodeValue));
          break;
        case "viewerId":
          _viewerId = nodeValue;
          _tripEventSink.add(TripEvent.viewerJoined);
      }
    });
    _tripEventSink.add(TripEvent.joined);
    _joined = true;
  }

  @override
  Future<void> watch(String viewerId) async {
    if (_watching || _joined) {
      return _tripEventSink.add(TripEvent.cantWatchAlreadyJoinedTrip);
    }
    final viewerIdNode = _firebaseDb.child("viewerId");
    if ((await viewerIdNode.once()).exists) {
      return _tripEventSink.add(TripEvent.tripAlreadyBeenWatched);
    }
    viewerIdNode.set(viewerId);
    join();
    _watching = true;
  }

  @override
  Future<void> leave() async {
    await _roomStreamsSubscription?.cancel();
    await _locationSourceStreamSubscription?.cancel();
    await _tripEventStreamController.close();
    await _locationStreamController.close();
  }
}
