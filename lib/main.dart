import 'dart:async';
import 'dart:developer';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

const LocationSettings locationSettings = LocationSettings(
  accuracy: LocationAccuracy.bestForNavigation,
  distanceFilter: 0,
);

late StreamSubscription<Position> positionStream;


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  final String title = 'Flutter Demo Home Page';

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

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

            ElevatedButton(
              onPressed: ()  async {
               await _determinePosition();
                getUserPositionAndWrites();
              },
              child: const Text('Start'),
            ),

            ElevatedButton(
              onPressed: ()  async {
                getUserPositionAndWritesStop();
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


Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}

getUserPositionAndWrites() {
  positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position? position) {
        log(position == null ? 'Unknown' : '${position.latitude.toString()}, ${position.longitude.toString()}');
        log(position == null ? 'Unknown' : position.timestamp.toString());
      });

}

getUserPositionAndWritesStop() {
  positionStream.cancel();
}

void _generateCsvFile() async {

  DateTime now = DateTime.now();
  String formattedDate1 = DateFormat('HH:mm:ss').format(now);

  List<dynamic> associateList = [
    {"number": 1, "lat": "14.97534313396318", "lon": "101.22998536005622", "time": formattedDate1},
    {"number": 2, "lat": "14.97534313396318", "lon": "101.22998536005622", "time": formattedDate1},
    {"number": 3, "lat": "14.97534313396318", "lon": "101.22998536005622", "time": formattedDate1},
    {"number": 4, "lat": "14.97534313396318", "lon": "101.22998536005622", "time": formattedDate1},
    {"number": 5, "lat": "14.97534313396318", "lon": "101.22998536005622", "time": formattedDate1}
  ];

  List<List<dynamic>> rows = [];

  List<dynamic> row = [];
  row.add("number");
  row.add("latitude");
  row.add("longitude");
  row.add("time");
  rows.add(row);
  for (int i = 0; i < associateList.length; i++) {
    List<dynamic> row = [];
    row.add(associateList[i]["number"] - 1);
    row.add(associateList[i]["lat"]);
    row.add(associateList[i]["lon"]);
    row.add(associateList[i]["time"]);
    rows.add(row);
  }

  String csv = const ListToCsvConverter().convert(rows);


  String formattedDate = DateFormat('yyyy-MM-dd, HH-mm').format(now);
  log(formattedDate.toString());

  String file = "/storage/emulated/0/Documents/Flutter";


  Directory(file).createSync();

  File f = File('$file/$formattedDate.csv');



  await f.create();

  f.writeAsString(csv);
}