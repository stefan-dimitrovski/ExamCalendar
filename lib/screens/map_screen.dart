import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_calendar/domain/directions_model.dart';
import 'package:exam_calendar/domain/exam.dart';
import 'package:exam_calendar/domain/repository/directions_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _controller;
  final Set<Marker> _markers = {};
  late Marker userMarker;
  Directions? _info;

  static const CameraPosition _initalCamera = CameraPosition(
    target: LatLng(41.994855, 21.431745),
    zoom: 5,
  );

  _getCurrentLocation() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    List<Placemark> placemark = await placemarkFromCoordinates(
        _locationData.latitude!, _locationData.longitude!);

    userMarker = Marker(
      markerId: const MarkerId('user'),
      position: LatLng(_locationData.latitude!, _locationData.longitude!),
      infoWindow: InfoWindow(
        title: 'Your location',
        snippet: placemark[0].thoroughfare,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    _markers.add(userMarker);
  }

  _getDirections(
      double lat, double lng, double latitude, double longitude) async {
    final directions = await DirectionsRepository().getDirections(
        origin: LatLng(lat, lng), destination: LatLng(latitude, longitude));

    setState(() => _info = directions!);
  }

  _getMarkers() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    final examRef = firestore.collection('exams').withConverter<Exam>(
          fromFirestore: (snapshot, _) => Exam.fromJson(snapshot.data()!),
          toFirestore: (exam, _) => exam.toJson(),
        );

    examRef
        .where("userId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        setState(
          () {
            _markers.add(
              Marker(
                onTap: (() {
                  _info = null;
                  _getDirections(
                      doc.data().lat,
                      doc.data().lng,
                      userMarker.position.latitude,
                      userMarker.position.longitude);
                }),
                markerId: MarkerId(doc.id),
                position: LatLng(doc.data().lat, doc.data().lng),
                infoWindow: InfoWindow(
                  title: doc.data().street,
                  snippet: doc.data().sublocality == ""
                      ? doc.data().administrativeArea
                      : doc.data().sublocality,
                ),
              ),
            );
          },
        );
      }
    });
  }

  void _addMarker(LatLng pos) {
    Marker _marker;
    setState(() {
      _marker = Marker(
          markerId: MarkerId(pos.toString()),
          infoWindow: InfoWindow(title: pos.toString()),
          position: pos);
      _markers.add(_marker);
    });
  }

  @override
  void initState() {
    _getCurrentLocation();
    _getMarkers();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: "Get current location",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Getting your location..."),
              ));
              setState(() {
                _getCurrentLocation();
              });
            },
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            onLongPress: _addMarker,
            markers: _markers,
            polylines: {
              if (_info != null)
                Polyline(
                    polylineId: const PolylineId('overview_polyline'),
                    color: Colors.red,
                    width: 5,
                    points: _info!.polylinePoints
                        .map((e) => LatLng(e.latitude, e.longitude))
                        .toList())
            },
            mapType: MapType.normal,
            rotateGesturesEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _initalCamera,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
          ),
          if (_info != null)
            Positioned(
              top: 20.0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                decoration: BoxDecoration(
                    color: Colors.yellowAccent,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 6.0,
                      )
                    ]),
                child: Text(
                  '${_info?.totalDistance}, ${_info?.totalDuration}',
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.w600),
                ),
              ),
            )
        ],
      ),
    );
  }
}
