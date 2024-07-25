import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class userlocation extends StatefulWidget {
  const userlocation({Key? key}) : super(key: key);

  @override
  _userlocationState createState() => _userlocationState();
}

class _userlocationState extends State<userlocation> {
  Completer<GoogleMapController> _controller = Completer();

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(35.3247, 75.5510),
    zoom: 14,
  );
  static const LatLng _center = const LatLng(33.738045, 73.084488);
  final Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  List<LatLng> latlng = [
    LatLng(35.3247, 75.5510),
    LatLng(35.35873670419323, 75.60628978804324),
    LatLng(35.30483498803142, 75.63104615753312),
    LatLng(35.368682997530236, 75.64505462657966),
    LatLng(35.3008094187224, 75.63260902387388)
  ];

  @override
  void initState() {
    super.initState();
    _addMarkers();
    _drawPolyline(latlng);
  }

  void _addMarkers() {
    for (int i = 0; i < latlng.length; i++) {
      _markers.add(Marker(
        markerId: MarkerId(i.toString()),
        position: latlng[i],
        infoWindow: InfoWindow(
          title: 'Marker $i',
          snippet: '5 Star Rating',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    }
  }

  void _drawPolyline(List<LatLng> points) {
    _polylines.add(Polyline(
      polylineId: PolylineId('polyline'),
      points: points,
      color: Colors.blue,
      width: 5,
    ));
  }

  void _onCameraMove(CameraPosition position) {
    // Example: Update the polyline with the new camera position
    List<LatLng> updatedPoints = [
      position.target,
      LatLng(position.target.latitude + 0.01, position.target.longitude + 0.01),
    ];
    setState(() {
      _polylines.clear(); // Clear existing polyline
      _drawPolyline(updatedPoints); // Draw updated polyline
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('google map'),
        ),
        body: GoogleMap(
          polylines: _polylines,
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          myLocationEnabled: true,
          onCameraMove: _onCameraMove,
          initialCameraPosition: _kGooglePlex,
          mapType: MapType.normal,
        ),
      ),
    );
  }
}
