import 'package:equatable/equatable.dart';
import 'package:location/location.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class HomeStartedCurrentLocationEvent extends HomeEvent {

  const HomeStartedCurrentLocationEvent();

  @override
  List<Object> get props => [];
}

class HomeNewDataUserSpeedAndDistanceEvent extends HomeEvent {
  final LocationData currentLocation;

  const HomeNewDataUserSpeedAndDistanceEvent({required this.currentLocation});

  @override
  List<Object> get props => [currentLocation];
}

class HomeResumedCurrentLocationEvent extends HomeEvent {

  const HomeResumedCurrentLocationEvent();

  @override
  List<Object> get props => [];
}