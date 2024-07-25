import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart'
    as geocoding; // Alias for geocoding package
import 'package:location/location.dart' as location_package;
import 'package:skardubazar/views/googlemap/location_service.dart';

import '../../models/location_model.dart'; // Alias for location package

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final LocationService _locationService = LocationService();
  static const LatLng sourceLocation = LatLng(35.3247, 75.5510);
  static const LatLng destination =
      LatLng(35.35873670419323, 75.60628978804324);
  LocationModel? _currentLocation;
  BitmapDescriptor _currentLocationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  LatLng? searchedLocation;

  Set<Marker> markers = {};
  Set<Polygon> polygons = {};

  final _searchTextController = TextEditingController();
  LatLng? startLocation;
  GoogleMapController? mapController;
  CameraPosition? cameraPosition;

  List<LatLng> latlng = [
    LatLng(35.305335652522594, 75.60913809089782),
    LatLng(35.291620793351775, 75.63448711465153),
    LatLng(35.29464197618635, 75.64264285331674),
    LatLng(35.30454359631509, 75.63451223520315),
    LatLng(35.3096, 75.6081),
   
  ];
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _setupInitialLocation();
    _setCustomMarkerIcon();
    _addMarkers();
  }

  void _setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/icons/Pin_current_location.png', // Replace with your custom icon path
    ).then((icon) {
      setState(() {
        _currentLocationIcon = icon;
      });
    });
  }

  void _setupInitialLocation() async {
    if (_currentLocation != null) {
      startLocation = LatLng(
        _currentLocation!.coordinates.latitude,
        _currentLocation!.coordinates.longitude,
      );
      _searchTextController.text = _currentLocation!.address;
    } else {
      var currentLoc = await _locationService.getCurrentLocation();
      setState(() {
        startLocation = LatLng(
          currentLoc.coordinates.latitude,
          currentLoc.coordinates.longitude,
        );
        _searchTextController.text = currentLoc.address;
        markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: startLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
            infoWindow: const InfoWindow(title: 'Current Location'),
          ),
        );
      });
    }
  }

  void _addMarkers() {
    for (int i = 0; i < latlng.length; i++) {
      markers.add(Marker(
        markerId: MarkerId(i.toString()),
        position: latlng[i],
        infoWindow: InfoWindow(
          title: 'Top nearset area shop',
          snippet: '5 Star Rating',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    }
  }

  void _animateToUserLocation(LatLng coordinates) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: startLocation!,
        zoom: 15.0,
      ),
    ));
  }

  Future<void> _searchLocation() async {
    String searchText = _searchTextController.text;

    try {
      List<geocoding.Location> locations =
          await geocoding.locationFromAddress(searchText);
      if (locations.isNotEmpty) {
        searchedLocation =
            LatLng(locations.first.latitude, locations.first.longitude);
        setState(() {
          markers.add(
            Marker(
              markerId: const MarkerId('searchedLocation'),
              position: searchedLocation!,
              infoWindow: InfoWindow(title: searchText),
            ),
          );
        });
        _animateToUserLocation(searchedLocation!);
        _drawPolygon();
      } else {
        print('No locations found for the given search text.');
      }
    } catch (e) {
      print('Error occurred while searching for the location: $e');
    }
  }

  void _drawPolygon() {
    if (startLocation != null && searchedLocation != null) {
      const double offset = 0.0005;

      polygons.add(
        Polygon(
          polygonId: const PolygonId('currentToSearched'),
          points: [
            LatLng(startLocation!.latitude + offset,
                startLocation!.longitude - offset),
            LatLng(startLocation!.latitude - offset,
                startLocation!.longitude + offset),
            LatLng(searchedLocation!.latitude - offset,
                searchedLocation!.longitude + offset),
            LatLng(searchedLocation!.latitude + offset,
                searchedLocation!.longitude - offset),
          ],
          strokeWidth: 2,
          strokeColor: Colors.red,
          fillColor: Colors.blue.withOpacity(0.01),
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Google Map',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: Stack(
        children: [
          startLocation == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: startLocation!,
                    zoom: 15.0,
                  ),
                  mapType: MapType.normal,
                  onMapCreated: (controller) {
                    _controller.complete(controller);
                    setState(() {
                      mapController = controller;
                    });
                  },
                  markers: markers,
                  polygons: polygons,
                  onCameraMove: (CameraPosition tempCameraPosition) {
                    cameraPosition = tempCameraPosition;
                  },
                  onCameraIdle: () async {
                    var address =
                        await _locationService.getAddressFromCoordinates(
                      LatLng(
                        cameraPosition!.target.latitude,
                        cameraPosition!.target.longitude,
                      ),
                    );
                    setState(() {
                      _searchTextController.text = address;
                    });
                  },
                ),
          Positioned(
            bottom: 100.0,
            left: 20.0,
            right: 20.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.only(left: 10),
              child: TextField(
                controller: _searchTextController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search',
                  suffixIcon: Icon(Icons.search),
                ),
                onSubmitted: (value) async {
                  await _searchLocation();
                },
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 30.0,
            right: 30.0,
            child: ElevatedButton(
              onPressed: () async {
                await _searchLocation();
              },
              child: const Text('Submit'),
            ),
          )
        ],
      ),
    );
  }
}
// class MapScreen extends StatefulWidget {
//   const MapScreen({Key? key}) : super(key: key);

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   final Completer<GoogleMapController> _controller = Completer();
//   final LocationService _locationService = LocationService();
//   static const LatLng sourceLocation = LatLng(35.3247, 75.5510);
//   static const LatLng destination =
//       LatLng(35.35873670419323, 75.60628978804324);
//   LocationModel? _currentLocation;
//   BitmapDescriptor _currentLocationIcon = BitmapDescriptor.defaultMarker;
//   BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
//   BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
//   LatLng? searchedLocation;

//   Set<Marker> markers = {};
//   Set<Polygon> polygons = {};

//   final _searchTextController = TextEditingController();
//   LatLng? startLocation;
//   GoogleMapController? mapController;
//   CameraPosition? cameraPosition;

//   @override
//   void initState() {
//     super.initState();
//     _setupInitialLocation();
//     _setCustomMarkerIcon();
//   }

//   void _setCustomMarkerIcon() {
//     BitmapDescriptor.fromAssetImage(
//       const ImageConfiguration(),
//       'assets/icons/Pin_current_location.png', // Replace with your custom icon path
//     ).then((icon) {
//       setState(() {
//         _currentLocationIcon = icon;
//       });
//     });
//   }

//   void _setupInitialLocation() async {
//     if (_currentLocation != null) {
//       startLocation = LatLng(
//         _currentLocation!.coordinates.latitude,
//         _currentLocation!.coordinates.longitude,
//       );
//       _searchTextController.text = _currentLocation!.address;
//     } else {
//       var currentLoc = await _locationService.getCurrentLocation();
//       setState(() {
//         startLocation = LatLng(
//           currentLoc.coordinates.latitude,
//           currentLoc.coordinates.longitude,
//         );
//         _searchTextController.text = currentLoc.address;
//         markers.add(
//           Marker(
//             markerId: const MarkerId('currentLocation'),
//             position: startLocation!,
//             icon: BitmapDescriptor.defaultMarkerWithHue(
//                 BitmapDescriptor.hueAzure),
//             infoWindow: const InfoWindow(title: 'Current Location'),
//           ),
//         );
//       });
//     }
//   }

//   void _animateToUserLocation(LatLng coordinates) async {
//     final GoogleMapController controller = await _controller.future;
//     controller.animateCamera(CameraUpdate.newCameraPosition(
//       CameraPosition(
//         target: startLocation!,
//         zoom: 15.0,
//       ),
//     ));
//   }

//   Future<void> _searchLocation() async {
//     String searchText = _searchTextController.text;

//     try {
//       List<geocoding.Location> locations =
//           await geocoding.locationFromAddress(searchText);
//       if (locations.isNotEmpty) {
//         searchedLocation =
//             LatLng(locations.first.latitude, locations.first.longitude);
//         setState(() {
//           markers.add(
//             Marker(
//               markerId: const MarkerId('searchedLocation'),
//               position: searchedLocation!,
//               infoWindow: InfoWindow(title: searchText),
//             ),
//           );
//         });
//         _animateToUserLocation(searchedLocation!);
//         _drawPolygon();
//       } else {
//         print('No locations found for the given search text.');
//       }
//     } catch (e) {
//       print('Error occurred while searching for the location: $e');
//     }
//   }

//   void _drawPolygon() {
//     if (startLocation != null && searchedLocation != null) {
//       // Define a small offset for creating a rectangle-like polygon
//       const double offset =
//           0.0005; // Adjust this value to make the polygon bigger or smaller

//       // Create a polygon that forms a rectangle around the line between the two points
//       polygons.add(
//         Polygon(
//           polygonId: const PolygonId('currentToSearched'),
//           points: [
//             LatLng(startLocation!.latitude + offset,
//                 startLocation!.longitude - offset), // Top-left
//             LatLng(startLocation!.latitude - offset,
//                 startLocation!.longitude + offset), // Bottom-right
//             LatLng(
//                 searchedLocation!.latitude - offset,
//                 searchedLocation!.longitude +
//                     offset), // Bottom-right of searched location
//             LatLng(
//                 searchedLocation!.latitude + offset,
//                 searchedLocation!.longitude -
//                     offset), // Top-left of searched location
//           ],
//           strokeWidth: 2,
//           strokeColor: Colors.red,
//           fillColor: Colors.blue.withOpacity(0.01),
//         ),
//       );
//       setState(() {});
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Google Map',
//           style: TextStyle(color: Colors.black, fontSize: 16),
//         ),
//       ),
//       body: Stack(
//         children: [
//           startLocation == null
//               ? const Center(child: CircularProgressIndicator())
//               : GoogleMap(
//                   initialCameraPosition: CameraPosition(
//                     target: startLocation!,
//                     zoom: 15.0,
//                   ),
//                   mapType: MapType.normal,
//                   onMapCreated: (controller) {
//                     _controller.complete(controller);
//                     setState(() {
//                       mapController = controller;
//                     });
//                   },
//                   markers: markers,
//                   polygons: polygons,
//                   onCameraMove: (CameraPosition tempCameraPosition) {
//                     cameraPosition = tempCameraPosition;
//                   },
//                   onCameraIdle: () async {
//                     var address =
//                         await _locationService.getAddressFromCoordinates(
//                       LatLng(
//                         cameraPosition!.target.latitude,
//                         cameraPosition!.target.longitude,
//                       ),
//                     );
//                     setState(() {
//                       _searchTextController.text = address;
//                     });
//                   },
//                 ),
//           Positioned(
//             bottom: 100.0,
//             left: 20.0,
//             right: 20.0,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               margin: const EdgeInsets.symmetric(horizontal: 10),
//               padding: const EdgeInsets.only(left: 10),
//               child: TextField(
//                 controller: _searchTextController,
//                 decoration: const InputDecoration(
//                   border: InputBorder.none,
//                   hintText: 'Search',
//                   suffixIcon: Icon(Icons.search),
//                 ),
//                 onSubmitted: (value) async {
//                   await _searchLocation();
//                 },
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 10,
//             left: 30.0,
//             right: 30.0,
//             child: ElevatedButton(
//               onPressed: () async {
//                 await _searchLocation();
//               },
//               child: const Text('Submit'),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

