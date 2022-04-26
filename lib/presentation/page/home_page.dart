import 'dart:async';
import 'dart:math';
import 'package:car_helper_gps/domain/blocs/home_bloc/home_bloc.dart';
import 'package:car_helper_gps/domain/blocs/home_bloc/home_event.dart';
import 'package:car_helper_gps/domain/blocs/home_bloc/home_state.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:location/location.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


bool itFitsPoint = false;
late StreamSubscription<LocationData> locationSubscription;
late List<dynamic> associateList = [];
Location location = Location();
int speedUser = 0;
late LocationData lastPoint;
double totalDistance = 0;
late HomeBloc bloc;

class MyHomePage extends StatefulWidget {
  final String title = 'Flutter Demo Home Page';

  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  bool isWriteGPSUserLocation = false;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<HomeBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            BlocConsumer<HomeBloc, HomeState>(
                builder: (context, state) {
                  return Column(
                    children: const [

                      Text('0 km/h'),
                      Text('0.0 km'),

                    ],
                  );
                },
              listener: (context, state) {
                if(state is HomeUpdateUserSpeedAndDistanceState) {

                  print(state.totalDistance.toString());

                  Column(
                    children: [

                      Text('${state.speed} km/h'),
                      Text('${state.totalDistance} km'),

                    ],
                  );
                }
              }
            ),

            ElevatedButton(
              onPressed: ()  async {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Start'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                if(isWriteGPSUserLocation !=true) _determinePosition(context);
                isWriteGPSUserLocation = true;
              },
              child: const Text('Start'),
            ),

            ElevatedButton(
              onPressed: ()  async {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Stop'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                if(isWriteGPSUserLocation !=false) writesUserAllRouteToFileAndStopGetUserLocation();
                isWriteGPSUserLocation = false;
              },
              child: const Text('Stop'),
            )

          ],
        ),
      ),
      floatingActionButton: const FloatingActionButton(
        onPressed: _generateCsvFile,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}


void _determinePosition(BuildContext context) async {
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

  locationSubscription = location.onLocationChanged.listen((LocationData currentLocation) {
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

  //  BlocProvider.of<HomeBloc>(context).add(HomeNewDataUserSpeedAndDistanceEvent(speed: speed, totalDistance: totalDistance));

    print('----------');
    print(speed.toString());
    print(output1.toString());
    print(totalDistance.toPrecision(2));
    print(distanceLastPoint.toPrecision(2));

    associateList.add({"№": number, "lat": currentLocation.latitude.toString(), "lon": currentLocation.longitude.toString(), "speed": speed, "totalDistance": totalDistance.toPrecision(2), "distanceLastPoint": distanceLastPoint.toPrecision(2), "time": output1});
    number++;
  });
}

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

double calculateDistance(lat1, lon1, lat2, lon2){
  var p = 0.017453292519943295;
  var a = 0.5 - cos((lat2 - lat1) * p)/2 + cos(lat1 * p) * cos(lat2 * p) *
      (1 - cos((lon2 - lon1) * p))/2;
  return 12742 * asin(sqrt(a));
}

writesUserAllRouteToFileAndStopGetUserLocation() {
  if(itFitsPoint != false) itFitsPoint = false;
  locationSubscription.cancel();
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


class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state);
}