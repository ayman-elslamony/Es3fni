import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/models/user_data.dart';

class ShowSpecificUserLocation extends StatefulWidget {
  final UserData userData;
  ShowSpecificUserLocation({@required this.userData});

  @override
  State<StatefulWidget> createState() => ShowSpecificUserLocationState();
}

class ShowSpecificUserLocationState extends State<ShowSpecificUserLocation>
    with SingleTickerProviderStateMixin {

  LatLng _currentPosition;
  GoogleMapController _mapController;
  MarkerId markerId;
  GoogleMap myMap;
  BitmapDescriptor customIcon;
  Set<Marker> markers;
  final CameraPosition _initialCamera =
  CameraPosition(target: LatLng(30.033333, 31.233334), zoom: 18);
  @override
  void initState() {
    super.initState();
    _currentPosition = LatLng(double.parse(widget.userData.lat), double.parse(widget.userData.lng));//_auth.myLatLng;
    print(_currentPosition);
    markers = Set.from([]);
    markerId = MarkerId(widget.userData.name);
    markers.add(Marker(
      visible: true,
        markerId: markerId,
        position: LatLng(double.parse(widget.userData.lat), double.parse(widget.userData.lng)),
        infoWindow: InfoWindow(
            title: widget.userData.name,
            snippet: widget.userData.address,
            onTap: () {
            }
            )));
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: InfoWidget(
        builder: (context,infoWidget)=>
        Scaffold(
          appBar: AppBar(
            shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40))),
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: infoWidget.orientation == Orientation.portrait
                      ? infoWidget.screenWidth * 0.05
                      : infoWidget.screenWidth * 0.035,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ),
          body: GoogleMap(
            mapToolbarEnabled: true,
            myLocationEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
            scrollGesturesEnabled: true,
            markers: markers,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
              });
//            _mapController.showMarkerInfoWindow(markerId
//            );
            },
            initialCameraPosition: _currentPosition == null?_initialCamera:CameraPosition(
                target:_currentPosition,
                zoom: 14.0),
          ),
        ),
      ),
    );
  }
}