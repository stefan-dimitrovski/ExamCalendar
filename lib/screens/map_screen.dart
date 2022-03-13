import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_calendar/models/exam.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _controller;
  final Set<Marker> _markers = {};

  static const CameraPosition _initalCamera = CameraPosition(
    target: LatLng(41.994855, 21.431745),
    zoom: 5,
  );

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

  @override
  void initState() {
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
      ),
      body: GoogleMap(
        onLongPress: _addMarker,
        markers: _markers,
        mapType: MapType.normal,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        initialCameraPosition: _initalCamera,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
      ),
    );
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
}
