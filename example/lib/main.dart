import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:dchs_motion_sensors/dchs_motion_sensors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Vector3 _accelerometer = Vector3.zero();
  final Vector3 _gyroscope = Vector3.zero();
  final Vector3 _magnetometer = Vector3.zero();
  final Vector3 _userAaccelerometer = Vector3.zero();
  final Vector3 _orientation = Vector3.zero();
  final Vector3 _absoluteOrientation = Vector3.zero();
  final Vector3 _absoluteOrientation2 = Vector3.zero();
  double? _screenOrientation = 0;

  int _groupValue = 0;

  @override
  void initState() {
    super.initState();
    motionSensors.gyroscope.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscope.setValues(event.x, event.y, event.z);
      });
    });
    motionSensors.accelerometer.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometer.setValues(event.x, event.y, event.z);
      });
    });
    motionSensors.userAccelerometer.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAaccelerometer.setValues(event.x, event.y, event.z);
      });
    });
    motionSensors.magnetometer.listen((MagnetometerEvent event) {
      setState(() {
        _magnetometer.setValues(event.x, event.y, event.z);
        final matrix =
            motionSensors.getRotationMatrix(_accelerometer, _magnetometer);
        _absoluteOrientation2.setFrom(motionSensors.getOrientation(matrix));
      });
    });
    motionSensors.isOrientationAvailable().then((available) {
      if (available) {
        motionSensors.orientation.listen((OrientationEvent event) {
          setState(() {
            _orientation.setValues(event.yaw, event.pitch, event.roll);
          });
        });
      }
    });
    motionSensors.absoluteOrientation.listen((AbsoluteOrientationEvent event) {
      setState(() {
        _absoluteOrientation.setValues(event.yaw, event.pitch, event.roll);
      });
    });
    motionSensors.screenOrientation.listen((ScreenOrientationEvent event) {
      setState(() {
        _screenOrientation = event.angle;
      });
    });
  }

  void setUpdateInterval(int? groupValue) {
    if (groupValue == null) {
      return;
    }

    final interval = switch (groupValue) {
      1 => Duration.microsecondsPerSecond ~/ 1,
      2 => Duration.microsecondsPerSecond ~/ 30,
      3 => Duration.microsecondsPerSecond ~/ 60,
      _ => Duration.microsecondsPerSecond ~/ 60,
    };

    motionSensors.accelerometerUpdateInterval = interval;
    motionSensors.userAccelerometerUpdateInterval = interval;
    motionSensors.gyroscopeUpdateInterval = interval;
    motionSensors.magnetometerUpdateInterval = interval;
    motionSensors.orientationUpdateInterval = interval;
    motionSensors.absoluteOrientationUpdateInterval = interval;
    setState(() {
      _groupValue = groupValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Motion Sensors'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Update Interval'),
              RadioGroup<int>(
                groupValue: _groupValue,
                onChanged: setUpdateInterval,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio<int>(value: 1),
                    Text('1 FPS'),
                    Radio<int>(value: 2),
                    Text('30 FPS'),
                    Radio<int>(value: 3),
                    Text('60 FPS'),
                  ],
                ),
              ),
              const Text('Accelerometer'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(_accelerometer.x.toStringAsFixed(4)),
                  Text(_accelerometer.y.toStringAsFixed(4)),
                  Text(_accelerometer.z.toStringAsFixed(4)),
                ],
              ),
              const Text('Magnetometer'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(_magnetometer.x.toStringAsFixed(4)),
                  Text(_magnetometer.y.toStringAsFixed(4)),
                  Text(_magnetometer.z.toStringAsFixed(4)),
                ],
              ),
              const Text('Gyroscope'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(_gyroscope.x.toStringAsFixed(4)),
                  Text(_gyroscope.y.toStringAsFixed(4)),
                  Text(_gyroscope.z.toStringAsFixed(4)),
                ],
              ),
              const Text('User Accelerometer'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(_userAaccelerometer.x.toStringAsFixed(4)),
                  Text(_userAaccelerometer.y.toStringAsFixed(4)),
                  Text(_userAaccelerometer.z.toStringAsFixed(4)),
                ],
              ),
              const Text('Orientation'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(degrees(_orientation.x).toStringAsFixed(4)),
                  Text(degrees(_orientation.y).toStringAsFixed(4)),
                  Text(degrees(_orientation.z).toStringAsFixed(4)),
                ],
              ),
              const Text('Absolute Orientation'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(degrees(_absoluteOrientation.x).toStringAsFixed(4)),
                  Text(degrees(_absoluteOrientation.y).toStringAsFixed(4)),
                  Text(degrees(_absoluteOrientation.z).toStringAsFixed(4)),
                ],
              ),
              const Text('Orientation (accelerometer + magnetometer)'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(degrees(_absoluteOrientation2.x).toStringAsFixed(4)),
                  Text(degrees(_absoluteOrientation2.y).toStringAsFixed(4)),
                  Text(degrees(_absoluteOrientation2.z).toStringAsFixed(4)),
                ],
              ),
              const Text('Screen Orientation'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text((_screenOrientation ?? 0).toStringAsFixed(4)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
