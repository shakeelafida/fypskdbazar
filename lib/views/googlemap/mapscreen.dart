import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../../models/location_model.dart';
import '../constant.dart';
import 'location_service.dart';

class mapscreen extends StatefulWidget {
  const mapscreen({Key? key}) : super(key: key);

  @override
  State<mapscreen> createState() => mapscreenState();
}

class mapscreenState extends State<mapscreen> {
  final Completer<GoogleMapController> _controller = Completer();
 final _locationService = LocationService();
  LocationModel? selectedLocation;
   final _addressController = TextEditingController();

  onLocationSelection(BuildContext context, LocationModel location) {
    setState(() {
      selectedLocation = location;
      _addressController.text = location.address;
    });
  }
  var currentLoc;
  static const LatLng sourceLocation = LatLng(35.3247, 75.5510);
  static const LatLng destination = LatLng(35.35873670419323, 75.60628978804324);
  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;
  

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor cuurrentLocationIcon = BitmapDescriptor.defaultMarker;
  
  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((location) {
      currentLocation = location;
    });
    GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              zoom: 13.5,
              target: LatLng(newLoc.latitude!, newLoc.longitude!))));
      setState(() {});
    });
  }
void getPolyPoints() async {
  try {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    '',
     //google_api,
      PointLatLng(sourceLocation!.latitude!, sourceLocation!.longitude!),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if (result.status == 'OK' && result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      setState(() {});
    } else {
      throw 'Failed to fetch polyline points: ${result.errorMessage}';
    }
  } catch (e) {
    print('Error getting polyline points: $e');
    // Show an error message or handle the error appropriately in your UI
  }
}
  // void getPolyPoints() async {
  //   PolylinePoints polylinePoints = PolylinePoints();
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //       'AIzaSyDIVIR1pR0UXt5oLbJtJhQIPoJ9jCdefLc',
  //       PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
  //       PointLatLng(destination.latitude, destination.longitude));
  //   if (result.points.isNotEmpty) {
  //     result.points.forEach((PointLatLng point) =>
  //         polylineCoordinates.add(LatLng(point.latitude, point.longitude)));
  //     setState(() {});
  //   }
  // }

  void setCustomerMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, 'assets/icons/Pin_source.png')
        .then((icon) {
      sourceIcon = icon;
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, 'assets/icons/Pin_destination.png')
        .then((icon) {
      destinationIcon = icon;
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, 'assets/icons/Badge.png')
        .then((icon) {
      cuurrentLocationIcon = icon;
    });
  }

  @override
  void initState() {
    getCurrentLocation();
    setCustomerMarkerIcon();
    //getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    currentLoc = _locationService.getCurrentLocation();
    
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Track order",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
        body: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                currentLoc!.c!, 
                currentLoc!.longitude!
              ),
              zoom: 13.5,
            ),
            // polylines: {
            //   Polyline(
            //     polylineId: PolylineId("route"),
            //     points: polylineCoordinates,
            //     color: Colors.blue,
            //     width: 6,
            //   ),
            // },
            markers: {
              Marker(
                icon: cuurrentLocationIcon,
                markerId: MarkerId('currentLocation'),
                position: LatLng(
                  selectedLocation!.coordinates.latitude,
                   selectedLocation!.coordinates.longitude
                ),
              ),
              Marker(
                icon: sourceIcon,
                markerId: MarkerId('source'),
                position: sourceLocation,
              ),
              // Marker(
              //   icon: destinationIcon,
              //   markerId: MarkerId('destination'),
              //   position: destination,
              // ),
            },
            onMapCreated: (mapController) {
              _controller.complete(mapController);
            },
            
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
//   LocationModel? _currentLocation;
//   BitmapDescriptor _currentLocationIcon = BitmapDescriptor.defaultMarker;
//   LatLng? sourceLocation;
//   LatLng? destination;
//   List<LatLng> polylineCoordinates = [];
//   List<LatLng> polygonCoordinates = [];
//   final _searchTextController = TextEditingController();
//   LatLng? startLocation;
//   GoogleMapController? mapController;
//   CameraPosition? cameraPosition;
//   LatLng? selectedLocation;

//   @override
//   void initState() {
//     super.initState();
//     _setupInitialLocation();
//     _setCustomMarkerIcon();
//     getPolyPoints();
//     _showPolygonBetweenLocations();
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

//   void getPolyPoints() async {
//     if (sourceLocation == null || destination == null) {
//       print('Source or destination location is null');
//       return;
//     }

//     try {
//       PolylinePoints polylinePoints = PolylinePoints();
//       PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//         'AIzaSyAhMrB2Iyb4r7KinlDnmZ4TA9alkvPFqqM', // Replace with your API key
//         PointLatLng(sourceLocation!.latitude, sourceLocation!.longitude),
//         PointLatLng(destination!.latitude, destination!.longitude),
//       );

//       if (result.status == 'OK' && result.points.isNotEmpty) {
//         polylineCoordinates.clear(); // Clear previous polyline coordinates
//         for (PointLatLng point in result.points) {
//           polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//         }
//         setState(() {});
//       } else {
//         throw 'Failed to fetch polyline points: ${result.errorMessage}';
//       }
//     } catch (e) {
//       print('Error getting polyline points: $e');
//       // Show an error message or handle the error appropriately in your UI
//     }
//   }

//   void _setupInitialLocation() async {
//     var currentLoc = await _locationService.getCurrentLocation();
//     setState(() {
//       _currentLocation = currentLoc;
//       startLocation = LatLng(
//         currentLoc.coordinates.latitude,
//         currentLoc.coordinates.longitude,
//       );
//       _searchTextController.text = currentLoc.address;
//       // Initialize the sourceLocation as the user's current location
//       sourceLocation = startLocation;
//     });
//   }

//   void _animateToUserLocation(LatLng coordinates) async {
//     final GoogleMapController controller = await _controller.future;
//     controller.animateCamera(CameraUpdate.newCameraPosition(
//       CameraPosition(
//         target: coordinates,
//         zoom: 15.0,
//       ),
//     ));
//   }

//   void _showPolygonBetweenLocations() {
//     if (selectedLocation != null && _currentLocation != null) {
//       polygonCoordinates = [
//         LatLng(_currentLocation!.coordinates.latitude,
//             _currentLocation!.coordinates.longitude),
//         selectedLocation!,
//       ];
//       setState(() {});
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'Track Order',
//             style: TextStyle(color: Colors.black, fontSize: 16),
//           ),
//         ),
//         body: Stack(
//           children: [
//             startLocation == null
//                 ? const Center(child: CircularProgressIndicator())
//                 : GoogleMap(
//                     initialCameraPosition: CameraPosition(
//                       target: startLocation!,
//                       zoom: 15.0,
//                     ),
//                     mapType: MapType.normal,
//                     onMapCreated: (controller) {
//                       _controller.complete(controller);
//                       setState(() {
//                         mapController = controller;
//                       });
//                     },
//                     markers: {
//                       if (startLocation != null)
//                         Marker(
//                           markerId: const MarkerId('currentLocation'),
//                           position: startLocation!,
//                           icon: _currentLocationIcon,
//                           infoWindow:
//                               const InfoWindow(title: 'Current Location'),
//                         ),
//                       if (selectedLocation != null)
//                         Marker(
//                           markerId: const MarkerId('selectedLocation'),
//                           position: selectedLocation!,
//                           icon: BitmapDescriptor.defaultMarkerWithHue(
//                               BitmapDescriptor.hueBlue),
//                           infoWindow:
//                               const InfoWindow(title: 'Selected Location'),
//                         ),
//                     },
//                     polygons: polygonCoordinates.isNotEmpty
//                         ? {
//                             Polygon(
//                               polygonId: const PolygonId('polygon'),
//                               points: polygonCoordinates,
//                               strokeWidth: 2,
//                               strokeColor: Colors.blue,
//                               fillColor: Colors.blue.withOpacity(0.2),
//                             ),
//                           }
//                         : {},
//                     polylines: polylineCoordinates.isNotEmpty
//                         ? {
//                             Polyline(
//                               polylineId: const PolylineId('polyline'),
//                               points: polylineCoordinates,
//                               color: Colors.blue,
//                               width: 3,
//                             ),
//                           }
//                         : {},
//                     onCameraMove: (CameraPosition tempCameraPosition) {
//                       cameraPosition = tempCameraPosition;
//                     },
//                     onCameraIdle: () async {
//                       var address =
//                           await _locationService.getAddressFromCoordinates(
//                         LatLng(
//                           cameraPosition!.target.latitude,
//                           cameraPosition!.target.longitude,
//                         ),
//                       );
//                       setState(() {
//                         _searchTextController.text = address;
//                       });
//                     },
//                   ),
//             Positioned(
//                 bottom: 100.0,
//                 left: 20.0,
//                 right: 20.0,
//                 child: Container(
//                   decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(15)),
//                   margin: const EdgeInsets.symmetric(horizontal: 10),
//                   padding: const EdgeInsets.only(left: 10),
//                   child: TextField(
//                     controller: _searchTextController,
//                     decoration: const InputDecoration(
//                       border: InputBorder.none,
//                       hintText: 'Search',
//                       suffixIcon: Icon(Icons.search),
//                     ),
//                     onSubmitted: (value) async {
//                       var location =
//                           await _locationService.getCurrentLocation();
//                       setState(() {
//                         selectedLocation = LatLng(
//                           location.coordinates.latitude,
//                           location.coordinates.longitude,
//                         );
//                         destination =
//                             selectedLocation; // Set destination as the selected location
//                       });
//                       _animateToUserLocation(selectedLocation!);
//                       _showPolygonBetweenLocations();
//                       getPolyPoints(); // Fetch the route between source and destination
//                     },
//                   ),
//                 )),
//             Positioned(
//                 bottom: 10,
//                 left: 30.0,
//                 right: 30.0,
//                 child: ElevatedButton(
//                   child: const Text('Choose Location'),
//                   onPressed: () {
//                     var lat = cameraPosition?.target.latitude ??
//                         startLocation!.latitude;
//                     var long = cameraPosition?.target.longitude ??
//                         startLocation!.longitude;
//                     selectedLocation = LatLng(lat, long);
//                     destination =
//                         selectedLocation; // Set destination as the chosen location
//                     _showPolygonBetweenLocations();
//                     getPolyPoints(); // Fetch the route between source and destination
//                   },
//                 )),
//           ],
//         ));
//   }
// }

// void getPolyPoints() async {
  //   try {
  //     PolylinePoints polylinePoints = PolylinePoints();
  //     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //       'YOUR_API_KEY', // Replace with your Google Maps API key
  //       PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
  //       PointLatLng(destination.latitude, destination.longitude),
  //     );

  //     if (result.status == 'OK' && result.points.isNotEmpty) {
  //       result.points.forEach((PointLatLng point) {
  //         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //       });
  //       setState(() {});
  //     } else {
  //       throw 'Failed to fetch polyline points: ${result.errorMessage}';
  //     }
  //   } catch (e) {
  //     print('Error getting polyline points: $e');
  //     // Show an error message or handle the error appropriately in your UI
  //   }
  // }
//static const LatLng sourceLocation = LatLng(35.3247, 75.5510);
  // static const LatLng destination =
  //     LatLng(35.35873670419323, 75.60628978804324);
  // List<LatLng> polylineCoordinates = [];