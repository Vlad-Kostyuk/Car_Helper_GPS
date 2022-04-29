import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  final int speed;
  final double totalDistance;

  const HomeState(this.speed, this.totalDistance);

  @override
  List<Object> get props => [speed, totalDistance];
}

class HomeInitial extends HomeState {

  const HomeInitial(int speed, double totalDistance) : super(speed, totalDistance);

}

class HomeStartedCurrentLocationState extends HomeState {

  const HomeStartedCurrentLocationState(int speed, double totalDistance) : super(speed, totalDistance);

}

class HomeUpdateUserSpeedAndDistanceState extends HomeState {

  const HomeUpdateUserSpeedAndDistanceState(int speed, double totalDistance) : super(speed, totalDistance);

}

class HomeResumedCurrentLocationState extends HomeState {

  const HomeResumedCurrentLocationState(int speed, double totalDistance) : super(speed, totalDistance);

}