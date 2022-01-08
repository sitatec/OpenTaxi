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

  Coordinates? _lastLocation;
  TripEvent? _lastEvent;
  String? _lastCustomEvent;

  final _locationStreamController = StreamController<Coordinates>.broadcast();
  final _tripEventStreamController = StreamController<TripEvent>.broadcast();
  final _customEventStreamController = StreamController<String>.broadcast();

  TripRoomImplementation(
    String id, {
    DatabaseReference? firebaseDb,
    Stream<Coordinates>? locationSourceStream,
  })  : _firebaseDb = firebaseDb ??
            FirebaseDatabase.instance.reference().child("trip_rooms/$id"),
        _driverId = id,
        // Currently the room id is the driver id.
        super._internal(id, locationSourceStream) {
    _locationStreamController.onListen = () {
      if (_lastLocation != null) {
        _locationStreamController.add(_lastLocation!);
      }
    };
    _tripEventStreamController.onListen = () {
      if (_lastEvent != null) {
        _emitTripEvent(_lastEvent!);
      }
    };
    _customEventStreamController.onListen = () {
      if (_lastCustomEvent != null) {
        _customEventStreamController.add(_lastCustomEvent!);
      }
    };
    _firebaseDb
        .child("riderId")
        .once()
        .then((snapshot) => _riderId = snapshot.value);
    _listenToSourceStreams();
  }

  void _listenToSourceStreams() {
    _locationSourceStreamSubscription =
        _locationSourceStream?.listen((location) {
      _firebaseDb.child("location").set(location.toMap());
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
  Stream<String> get customEventStream => _customEventStreamController.stream;

  @override
  void join() {
    if (_joined) {
      return _emitTripEvent(TripEvent.cantJoinTwice);
    }
    _roomStreamsSubscription =
        _firebaseDb.child(id).onChildChanged.listen((event) {
      final nodeKey = event.snapshot.key;
      final nodeValue = event.snapshot.value;
      switch (nodeKey) {
        case "location":
          if (_locationStreamController.hasListener) {
            _locationStreamController.add(Coordinates.fromMap(nodeValue));
          }
          _lastLocation = nodeValue;
          break;
        case "viewerId":
          _viewerId = nodeValue;
          _emitTripEvent(TripEvent.viewerJoined);
          break;
        case "event":
          if (_customEventStreamController.hasListener) {
            _customEventStreamController.add(nodeValue);
          }
          _lastCustomEvent = nodeValue;
      }
    });
    _emitTripEvent(TripEvent.joined);
    _joined = true;
  }

  void _emitTripEvent(TripEvent event) {
    if (_tripEventStreamController.hasListener) {
      _tripEventStreamController.add(event);
    }
    _lastEvent = event;
  }

  @override
  Future<void> watch(String viewerId) async {
    if (_watching || _joined) {
      return _tripEventStreamController
          .add(TripEvent.cantWatchAlreadyJoinedTrip);
    }
    final viewerIdNode = _firebaseDb.child("viewerId");
    if ((await viewerIdNode.once()).exists) {
      return _emitTripEvent(TripEvent.tripAlreadyBeenWatched);
    }
    viewerIdNode.set(viewerId);
    join();
    _watching = true;
  }

  @override
  Future<void> leave(String who) async {
    await _firebaseDb.child("event").set("${who}_left");
    await _roomStreamsSubscription?.cancel();
    await _locationSourceStreamSubscription?.cancel();
    await _tripEventStreamController.close();
    await _locationStreamController.close();
    await _customEventStreamController.close();
  }

  @override
  Future<void> sendCustomEvent(String event) =>
      _firebaseDb.child("event").set(event);
}
