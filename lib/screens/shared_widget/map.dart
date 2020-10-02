import 'dart:convert';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class GetUserLocation extends StatefulWidget {
  static const routeName = '/GetUserLocation';
  Function getAddress;

  GetUserLocation({this.getAddress});

  @override
  State<StatefulWidget> createState() => GetUserLocationState();
}


class GetUserLocationState extends State<GetUserLocation> with SingleTickerProviderStateMixin {
TextEditingController _textEditingController =TextEditingController();
TextEditingController _realAddressController =TextEditingController();
  List<dynamic> _placePredictions = [];
  BitmapDescriptor customIcon;
  Set<Marker> markers;
  @override
  void initState() {
    super.initState();
    markers = Set.from([]);
  }
  GoogleMapController _mapController;
  searchChangedNavigate(){

    locationFromAddress(_textEditingController.text).then((res) async{
      _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(res[0].latitude,res[0].longitude),zoom: 10.0)));
    });
  }
  final CameraPosition _initialCamera = CameraPosition(target: LatLng(30.03,31.23), zoom: 18);
  createMarker(context) {
    if (customIcon == null) {
      ImageConfiguration configuration = createLocalImageConfiguration(context);
      BitmapDescriptor.fromAssetImage(configuration, 'assets/icons/marker.png')
          .then((icon) {
        setState(() {
          customIcon = icon;
        });
      });
    }
  }
  double radius = 30000;
  void _autocompletePlace(String input) async {
    if (input.length > 0) {
      String url =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=AIzaSyC5rVumZ-Lyqa8Bk6qZ6llkLwWbX82hxWE&language=en";
      if ( _initialCamera.target != null && radius != null) {
        url += "&location=${_initialCamera.target.latitude},${_initialCamera.target.longitude}&radius=${radius}";
      }
      final response = await http.get(url);
      final json = jsonDecode(response.body);

      if (json["error_message"] != null) {
        var error = json["error_message"];
        if (error == "This API project is not authorized to use this API.")
          error += " Make sure the Places API is activated on your Google Cloud Platform";
        throw Exception(error);
      } else {
        final predictions = json["predictions"];
        setState(() => _placePredictions = predictions);
        print(_placePredictions);
      }
    } else {
      setState(() => _placePredictions = []);
    }
  }
  @override
  Widget build(BuildContext context) {
    createMarker(context);
    return InfoWidget(
      builder: (context,infoWidget)=>
      Scaffold(
        resizeToAvoidBottomPadding: true,
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
        body: Stack(
          children: <Widget>[
            GoogleMap(
              myLocationEnabled: true,
              compassEnabled: true,
              markers: markers,
              myLocationButtonEnabled: true,
              onTap: (pos) async{
                print(pos);
                Marker m =
                Marker(markerId: MarkerId('1'), icon: customIcon, position: pos);
                setState(() {
                  markers.add(m);
                });final coordinates =
                new Coordinates(pos.latitude, pos.longitude);
                var addresses =
                    await Geocoder.local.findAddressesFromCoordinates(coordinates);
                setState(() {
                  _realAddressController.text =addresses.first.addressLine;
                });
                showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0))),
                  contentPadding: EdgeInsets.only(top: 10.0),
                  title: Text(
                    translator.currentLanguage == "en" ?'Are you sure':'هل انت متأكد',
                    textAlign: TextAlign.center,
                  ),
                  content: Container(
                    height: 80,
                    child: Center(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(height: 60 ,width: MediaQuery.of(context).size.width/0.85,child: TextFormField(
                              //style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
                              controller: _realAddressController,
                              decoration: InputDecoration(
                              labelText: translator.currentLanguage == "en" ?'this is Your location':'ان هذا موقعك',
                                  labelStyle: TextStyle(color: Colors.indigo),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(
                                      color: Colors.indigo,
                                    ),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(
                                      color: Colors.indigo,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(color: Colors.indigo),
                                  ),
                              ),
                              keyboardType: TextInputType.text,
                            ),)
                          )
                      //,Text('this is Your location',style: TextStyle(fontSize: 18,color: Colors.indigo),),
                        ],
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(translator.currentLanguage == "en" ?'Cancel':'الغاء'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                    FlatButton(
                      child: Text(translator.currentLanguage == "en" ?'ok':'موافق'),
                      onPressed: () {
                        print(_realAddressController.text);
                         setState(() {
                           widget.getAddress(_realAddressController.text,pos.latitude,pos.longitude);
                         });
                        Navigator.of(ctx).pop();
                        Navigator.of(ctx).pop();
                      },
                    )
                  ],
                ));
              },
              onMapCreated: (controller) {
                setState(() {
                  _mapController = controller;
                });
              },
              initialCameraPosition:
              CameraPosition(target: LatLng(30.033333, 31.233334), zoom: 18),
            ),
            Positioned(
                top: 50,
                left: 0.0,
                right: 15,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.indigo,
                            size: 30,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          }),
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          textInputAction: TextInputAction.done,
                          controller: _textEditingController,
                          decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              labelStyle: TextStyle(color: Colors.black),
                              labelText: translator.currentLanguage == "en" ?'Search for Location':'ابحث عن موقع',
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(
                                  color: Colors.indigo,
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(
                                  color: Colors.indigo,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(color: Colors.indigo),
                              ),
                              prefixIcon: IconButton(
                                  onPressed: searchChangedNavigate,
                                  icon: Icon(
                                    Icons.search,
                                    color: Colors.indigo,
                                    size: 30,
                                  )),
                              suffixIcon: _textEditingController.text == null
                                  ? null
                                  : IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.indigo,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _placePredictions.clear();

                                      _textEditingController.clear();
                                    });
                                  })),
                          keyboardType: TextInputType.text,
                          onChanged: (val) {
                            setState(() {
                              _autocompletePlace(val);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                )),
            Positioned(
              top: 120,
              left: 15,
              right: 15,
              child:  _placePredictions.length == 0?SizedBox(height: 1.0,):Material(
                  shadowColor: Colors.indigoAccent,
                  elevation: 8.0,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  type: MaterialType.card,
              child:
              Container(
                  height: 180,
                  child: ListView.builder(itemBuilder: (ctx,index)=>InkWell(
                      onTap: (){
                        setState(() {
                          _textEditingController.text = _placePredictions[index]['description'];
                          searchChangedNavigate();
                          _placePredictions.clear();
                        });
                      },
                      child: ListTile(title: Text('${_placePredictions[index]['description']}'),)),itemCount: _placePredictions.length,))
              )
            )
          ],
        ),
      ),
    );
  }

}

