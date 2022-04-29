import 'dart:async';
import 'package:car_helper_gps/data/api/user_location_api.dart';
import 'package:car_helper_gps/domain/blocs/home_bloc/home_event.dart';
import 'package:car_helper_gps/domain/blocs/home_bloc/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:location/location.dart';

bool itFitsPoint = false;
late StreamSubscription<LocationData> locationSubscription;
late List<dynamic> associateList = [];
Location location = Location();
int speedUser = 0;
late LocationData lastPoint;
double totalDistance = 0;
late HomeBloc bloc;

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserLocationAPI _userLocation;

  StreamSubscription<LocationData>? _userLocationSubscription;

  HomeBloc({required UserLocationAPI userLocation}) : _userLocation = userLocation, super(HomeInitial(speedUser, totalDistance)) {
    on<HomeNewDataUserSpeedAndDistanceEvent>(_mapNewDataUserSpeedAndDistance);
    on<HomeStartedCurrentLocationEvent>(_mapStartedCurrentLocation);
    on<HomeResumedCurrentLocationEvent>(_mapResumedCurrentLocation);
  }

  @override
  Future<void> close() {
    _userLocationSubscription?.cancel();
    return super.close();
  }

  void _mapStartedCurrentLocation(HomeStartedCurrentLocationEvent event,  Emitter<HomeState> emit) {
    emit(HomeStartedCurrentLocationState(speedUser, totalDistance));
    _userLocationSubscription?.cancel();
    _userLocationSubscription = _userLocation.getLocation().listen((LocationData currentLocation) {
      add(HomeNewDataUserSpeedAndDistanceEvent(currentLocation: currentLocation));
    });
  }

  void _mapNewDataUserSpeedAndDistance(HomeNewDataUserSpeedAndDistanceEvent event, Emitter<HomeState> emit) {
    _determinePosition(event.currentLocation);
    print(speedUser.toString());
    emit(HomeUpdateUserSpeedAndDistanceState(speedUser, totalDistance));
  }

  void _mapResumedCurrentLocation(HomeResumedCurrentLocationEvent event, Emitter<HomeState> emit) {
    _userLocationSubscription?.cancel();
    writesUserAllRouteToFileAndStopGetUserLocation();
    emit(HomeResumedCurrentLocationState(speedUser, totalDistance));
  }
}


void _determinePosition(LocationData currentLocation) async {
  int number = 1;
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  double distanceLastPoint = 0.0;
  location.enableBackgroundMode(enable: true);
  location.changeSettings(distanceFilter: 0, accuracy: LocationAccuracy.high);

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return;
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    print('Location permissions are denied');
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return;
    }
  }


    if(itFitsPoint == false) {
      lastPoint = currentLocation;
      itFitsPoint = true;
    }

    DateTime date = DateTime.fromMillisecondsSinceEpoch(currentLocation.time!.toInt());
    String output1 = DateFormat('HH:mm:ss').format(date);

    int speed = (currentLocation.speed! * 3.6).toInt();
    speedUser = speed;

    distanceLastPoint = calculateDistance(lastPoint.latitude, lastPoint.longitude, currentLocation.latitude, currentLocation.longitude);
    totalDistance = totalDistance + distanceLastPoint;
    lastPoint = currentLocation;

    print('----------');
    print(speedUser.toString());
    print(output1.toString());
    print(totalDistance.toPrecision(2));
    print(distanceLastPoint.toPrecision(2));


    associateList.add({"№": number, "lat": currentLocation.latitude.toString(), "lon": currentLocation.longitude.toString(), "speed": speedUser, "totalDistance": totalDistance.toPrecision(2), "distanceLastPoint": distanceLastPoint.toPrecision(2), "time": output1});
    number++;

}

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

double calculateDistance(lat1, lon1, lat2, lon2){
  double p = 0.017453292519943295;
  double a = 0.5 - cos((lat2 - lat1) * p)/2 + cos(lat1 * p) * cos(lat2 * p) *
      (1 - cos((lon2 - lon1) * p))/2;
  return 12742 * asin(sqrt(a));
}

void writesUserAllRouteToFileAndStopGetUserLocation() {
  if(itFitsPoint != false) itFitsPoint = false;
  _generateCsvFile();
}

void _generateCsvFile() async {
  DateTime now = DateTime.now();

  List<List<dynamic>> rows = [];

  List<dynamic> row = [];
  row.add("№");
  row.add("latitude");
  row.add("longitude");
  row.add("speed");
  row.add("totalDistance");
  row.add("distanceLastPoint");
  row.add("time");
  rows.add(row);
  for (int i = 0; i < associateList.length; i++) {
    List<dynamic> row = [];
    row.add(associateList[i]["№"] - 1);
    row.add(associateList[i]["lat"]);
    row.add(associateList[i]["lon"]);
    row.add(associateList[i]["speed"]);
    row.add(associateList[i]["totalDistance"]);
    row.add(associateList[i]["distanceLastPoint"]);
    row.add(associateList[i]["time"]);
    rows.add(row);
  }

  String csv = const ListToCsvConverter().convert(rows);

  String formattedDate = DateFormat('yyyy-MM-dd, HH-mm').format(now);
  print(formattedDate.toString());

  String file = "/storage/emulated/0/Documents/Flutter";

  Directory(file).createSync();

  File f = File('$file/$formattedDate.csv');

  await f.create();

  f.writeAsString(csv);
}

