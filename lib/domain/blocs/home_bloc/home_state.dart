import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {

  const HomeInitial();

  @override
  List<Object> get props => [];
}

class HomeUpdateUserSpeedAndDistanceState extends HomeState {
  final int speed;
  final double totalDistance;

  const HomeUpdateUserSpeedAndDistanceState({required this.speed, required this.totalDistance});

  @override
  List<Object> get props => [];
}