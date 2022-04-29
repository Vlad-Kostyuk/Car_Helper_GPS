import 'package:car_helper_gps/domain/blocs/home_bloc/home_bloc.dart';
import 'package:car_helper_gps/domain/blocs/home_bloc/home_event.dart';
import 'package:car_helper_gps/domain/blocs/home_bloc/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyHomePage extends StatefulWidget {
  final String title = 'Flutter Demo Home Page';

  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  late HomeBloc bloc;
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

            BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  final int speedUser = context.select((HomeBloc bloc) =>  bloc.state.speed);
                  final double totalDistance = context.select((HomeBloc bloc) => bloc.state.totalDistance);

                  return Column(
                    children: [
                      Text('$speedUser km/h'),
                      Text('$totalDistance km'),
                    ],
                  );
                },
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
                if(isWriteGPSUserLocation !=true) bloc.add(const HomeStartedCurrentLocationEvent());
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
                if(isWriteGPSUserLocation !=false) bloc.add(const HomeResumedCurrentLocationEvent ());
                isWriteGPSUserLocation = false;
              },
              child: const Text('Stop'),
            )

          ],
        ),
      ),
    );
  }
}
