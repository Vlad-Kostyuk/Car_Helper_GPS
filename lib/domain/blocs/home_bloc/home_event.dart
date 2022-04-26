import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class HomeNewDataUserSpeedAndDistanceEvent extends HomeEvent {
  final int speed;
  final double totalDistance;

  const HomeNewDataUserSpeedAndDistanceEvent({required this.speed, required this.totalDistance});

  @override
  List<Object> get props => [];
}