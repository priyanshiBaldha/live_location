import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  getLocationPermission() async {
    PermissionStatus status = await Permission.location.request();

    if (status.isDenied) {
      Permission.location.request();
    }
  }

  double lat = 0;
  double long = 0;

  Placemark placemark = Placemark();

  @override
  void initState() {
    super.initState();
    getLocationPermission();
  }

  Completer<GoogleMapController> cnt = Completer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Location"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 50,
            ),
            Expanded(
              child: GoogleMap(
                onMapCreated: (c) {
                  setState(() {
                    cnt.complete(c);
                  });
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: LatLng(lat, long),
                  zoom: 70,
                  tilt: 0,
                  bearing: 0,
                ),
              ),
            ),
            const SizedBox(height: 50,),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (await Permission.location.isDenied) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text(
                  ("ALERT...!!"),
                ),
                content: const Text(
                    "Please Allow the location permission from Settings..."),
                actions: [
                  ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await openAppSettings();
                      },
                      icon: const Icon(Icons.settings),
                      label: const Text("Settings"))
                ],
              ),
            );
          } else {
            setState(() {
              Geolocator.getPositionStream().listen((e) async {
                lat = e.latitude;
                long = e.longitude;
                List<Placemark> places =
                await placemarkFromCoordinates(lat, long);
                placemark = places[0];
              });
            });
          }
        },
        child: const Icon(Icons.gps_fixed_outlined),
      ),
    );
  }
}
