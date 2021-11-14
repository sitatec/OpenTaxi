import 'package:meta/meta.dart';
import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

part 'trip_room_implementation.dart';

abstract class TripRoom {
  final String id;

  Stream<Location> get locationStream;
  Stream<double> get speedStream;
  Stream<TripEvent> get tripEventsStream;

  String get riderId;
  String get driverId;
  String? get viewerId;

  factory TripRoom(String id) => TripRoomImplementation(id);

  TripRoom._internal(this.id);

  void join();

  Future<void> leave();

}

class Location {
  final double latitude;
  final double longitude;

  const Location({required this.latitude, required this.longitude});

  static Location fromString(String location) {
    final coordinates = location.split(',').map((e) => double.parse(e));
    return Location(latitude: coordinates.first, longitude: coordinates.last);
  }

}

enum TripEvent {
  joined,
  joinFailed,
  viewerJoined,
}