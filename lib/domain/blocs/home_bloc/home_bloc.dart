import 'package:car_helper_gps/domain/blocs/home_bloc/home_event.dart';
import 'package:car_helper_gps/domain/blocs/home_bloc/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {

  HomeBloc() : super(const HomeInitial()) {
    on<HomeNewDataUserSpeedAndDistanceEvent>(_mapButtonSave);
  }

  void _mapButtonSave(HomeNewDataUserSpeedAndDistanceEvent event, Emitter<HomeState> emit) {
    emit(HomeUpdateUserSpeedAndDistanceState(speed: event.speed, totalDistance: event.totalDistance));
  }
}

