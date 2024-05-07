import 'dart:collection';

import 'package:appclientes/shared/common.dart';
import 'package:appclientes/v_gmap/controller/map_controller.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GMapView extends StatefulWidget {
  final Position position;
  GMapView({Key key, this.position}) : super(key: key);

  @override
  _GMapViewState createState() => _GMapViewState();
}

class _GMapViewState extends State<GMapView> {
  Set<Marker> _markers = HashSet<Marker>();
  GoogleMapController _mapController;
  Position _position;
  final Position _defaultPosition =
      Position(latitude: -12.060322, longitude: -77.041551);

  @override
  void initState() {
    if (widget.position is Position) _position = widget.position;
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    if (widget.position is Position)
      setState(() => _markers.add(GMapController.geoMarker(widget.position)));
    else
      setState(() => _markers.add(GMapController.geoMarker(_defaultPosition)));
  }

  void _handleTap(LatLng point) {
    _markers.clear();
    _position = Position(latitude: point.latitude, longitude: point.longitude);
    setState(() => _markers.add(GMapController.marker(point)));
    GMapController.redirectToLocation(_mapController, point);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: GMapController.geoCameraPosition(
              widget.position ?? _defaultPosition),
          markers: _markers,
          onTap: _handleTap,
          onLongPress: _handleTap,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton:
            Buttons.yellow("Selecciona este punto", paddingH: 1, onClick: () {
          Navigator.pop(context, _position ?? _defaultPosition);
        }),
      ),
    );
  }
}
