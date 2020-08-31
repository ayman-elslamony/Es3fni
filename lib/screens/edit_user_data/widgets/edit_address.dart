import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:helpme/screens/shared_widget/map.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class EditAddress extends StatefulWidget {
  final String address;
  final Function getAddress;

  EditAddress({this.getAddress,this.address});

  @override
  _EditAddressState createState() => _EditAddressState();
}

class _EditAddressState extends State<EditAddress> {
  bool _isEditLocationEnable = false;
  bool _selectUserLocationFromMap = false;
  TextEditingController _locationTextEditingController = TextEditingController();
  Future<String> _getLocation() async {
    Position position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final coordinates = new Coordinates(position.latitude, position.longitude);

    var addresses =
    await Geocoder.local.findAddressesFromCoordinates(coordinates);
    return addresses.first.addressLine;
  }

  void _getUserLocation() async {
    var address = await _getLocation();
    widget.getAddress(address);
    setState(() {
      _locationTextEditingController.text = address;
      _isEditLocationEnable = true;
      _selectUserLocationFromMap = !_selectUserLocationFromMap;
    });
    Navigator.of(context).pop();
  }

  void selectLocationFromTheMap(String addresss, double lat, double long) {
    setState(() {
      _locationTextEditingController.text = addresss;
    });
    widget.getAddress(addresss);
  }
  void selectUserLocationType() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0))),
        contentPadding: EdgeInsets.only(top: 10.0),
        title: Text(
          translator.currentLanguage == "en" ?'Location':'الموقع',
          textAlign: TextAlign.center,
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                InkWell(
                  onTap: _getUserLocation,
                  child: Material(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      type: MaterialType.card,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          translator.currentLanguage == "en" ?'Get current Location':'الحصول على الموقع الحالى',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      )),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (ctx) => GetUserLocation(
                          getAddress: selectLocationFromTheMap,
                        )));
                    setState(() {
                      _isEditLocationEnable = true;
                      _selectUserLocationFromMap = !_selectUserLocationFromMap;
                    });
                  },
                  child: Material(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      type: MaterialType.card,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          translator.currentLanguage == "en" ?'Select Location from Map':'اختر موقع من الخريطه',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      )),
                ),
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
          )
        ],
      ),
    );
  }
  @override
  void initState() {
    if(widget.address !=null){
      _locationTextEditingController.text= widget.address;
      _isEditLocationEnable = true;
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: selectUserLocationType,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 7.0),
          height: 80,
          child: TextFormField(
            autofocus: false,
            style: TextStyle(fontSize: 15),
            controller: _locationTextEditingController,
            textInputAction: TextInputAction.done,
            enabled: _isEditLocationEnable,
            decoration: InputDecoration(
              suffixIcon: InkWell(
                onTap: selectUserLocationType,
                child: Icon(
                  Icons.my_location,
                  size: 20,
                  color: Colors.indigo,
                ),
              ),
              labelText: translator.currentLanguage == "en" ?'Location':'الموقع',
              focusedBorder: OutlineInputBorder(
                borderRadius:
                BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(
                  color: Colors.indigo,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius:
                BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(
                  color: Colors.indigo,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(color: Colors.indigo),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius:
                BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(color: Colors.indigo),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius:
                BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(color: Colors.indigo),
              ),
            ),
            keyboardType: TextInputType.text,
            autovalidate: true,
// ignore: missing_return
            validator: (String val) {
              if (val.trim().isEmpty) {
                return translator.currentLanguage == "en" ?'Invalid Location':'الموقع غير متاح';
              }
            },
          ),
        ));
  }
}
