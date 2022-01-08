import 'package:location_manager/location_manager.dart';
import 'package:meta/meta.dart';
import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

part 'trip_room_implementation.dart';

abstract class TripRoom {
  final String id;
  final Stream<Coordinates>? _locationSourceStream;
  Stream<Coordinates> get locationStream;

  Stream<TripEvent> get tripEventsStream;

  Stream<String> get customEventStream;

  String get riderId;

  String get driverId;

  String? get viewerId;

  factory TripRoom(
    String id, {
    Stream<Coordinates>? locationSourceStream,
  }) =>
      TripRoomImplementation(
        id,
        locationSourceStream: locationSourceStream,
      );

  TripRoom._internal(
    this.id,
    this._locationSourceStream,
  );

  void join();

  Future<void> watch(String viewerId);

  Future<void> leave(String who);

  Future<void> sendCustomEvent(String event);
}

enum TripEvent {
  joined,
  joinFailed,
  viewerJoined,
  cantWatchAlreadyJoinedTrip,
  tripAlreadyBeenWatched,
  cantJoinTwice,
}
