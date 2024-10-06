import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:locket_flutter/components/toast.dart';

class MapNavigation extends StatefulWidget {
  final double lat;
  final double long;
  const MapNavigation({super.key, required this.lat, required this.long});

  @override
  State<MapNavigation> createState() => _MapNavigationState();
}

class _MapNavigationState extends State<MapNavigation> {
  final Completer<GoogleMapController> _controller = Completer();
  
  List<LatLng> polylineCoordinates = [];
  // LocationData? currentLocation;
  LatLng? sourceLocation;
  Position? currentLocation;
  StreamSubscription<Position>? _positionStream;

    // Animation variables
  AnimationController? _animationController;
  Animation<LatLng>? _animation;

  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  void getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
        currentLocation = position;
        sourceLocation = LatLng(position.latitude!, position.longitude!);
        getPolyPoints(position.longitude!, position.latitude!);
    }).catchError((e) {
      debugPrint(e);
    });

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, 
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) async {
      setState(() {
        currentLocation = position;
      });
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 16, 
        tilt: 30,  
      )));
    });

  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> getPolyPoints(double longi, double lati) async {
    final String osrmUrl = 'https://router.project-osrm.org/route/v1/driving/$longi,$lati;${widget.long},${widget.lat}?geometries=geojson';

    try {
      final response = await http.get(Uri.parse(osrmUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];

        // Clear previous coordinates
        polylineCoordinates.clear();

        // Convert the coordinates to LatLng format
        for (var coord in coordinates) {
          polylineCoordinates.add(LatLng(coord[1], coord[0]));
        }

        setState(() {});
      } else {
        showToast(message: "Error fetching route: ${response.statusCode}");
      }
    } catch (e) {
      showToast(message: "Error: $e");
    }
  }

  void setCustomMarkerIcon() {
    BitmapDescriptor.asset(const ImageConfiguration(size: Size(24, 24)), "assets/images/arrow.png").then(
      (icon) {
        currentLocationIcon = icon; 
      } 
    );
  }

  @override 
  void initState() {
    getCurrentLocation();
    super.initState();
    setCustomMarkerIcon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xff211a2c),
        title: const Text("Order navigation", style: TextStyle(color: Color(0xffffaf36))),
      ),
      body: (currentLocation == null || sourceLocation == null) 
        ? const Center(child: Text("Loading navigation")) 
        : GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
              zoom: 16,
            ),
            polylines: {
              Polyline(
                polylineId: PolylineId("route"),
                points: polylineCoordinates,
                color: const Color.fromARGB(255, 55, 132, 195),
                width: 6,
              ),
            },
            markers: {
              Marker(
                markerId: MarkerId("current"),
                icon: currentLocationIcon,
                rotation: currentLocation!.heading == null ? 0 : currentLocation!.heading!,
                position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
              ),
              Marker(
                markerId: MarkerId("destination"),
                position: LatLng(widget.lat, widget.long),
              ),
            },
            onMapCreated: (mapController) {
              _controller.complete(mapController);
            },
          ),
    );
  }
}
