import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class PersonalInfoCard extends StatefulWidget {
  final String address;
  final String governorate;
  final String gender;
  final String phoneNumber;
  final String email;
  final TextStyle title;
  final TextStyle subTitle;
  final double width;
  final Orientation orientation;
  PersonalInfoCard(
      {this.address,
        this.width,this.orientation,
      this.governorate,
      this.gender,
      this.phoneNumber,
        this.subTitle,
        this.title,
      this.email});

  @override
  _PersonalInfoCardState createState() => _PersonalInfoCardState();
}

class _PersonalInfoCardState extends State<PersonalInfoCard> {
  bool _showPersonalInfo = true;

  Widget _data({String title, String content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title + " ",
            style: widget.subTitle.copyWith(color: Colors.black,fontWeight: FontWeight.w600)
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Column(
               // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    content,
                    style: widget.subTitle.copyWith(color: Color(0xff484848),fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: translator.currentLanguage == "en" ?TextDirection.ltr:TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
        child: Material(
          shadowColor: Colors.indigoAccent,
          elevation: 0.5,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          type: MaterialType.card,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                    onTap: () {
                      setState(() {
                        _showPersonalInfo = !_showPersonalInfo;
                      });
                    },
                    child:
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text( translator.currentLanguage == "en" ?"Personal Information":'المعلومات الشخصيه',
                              style: widget.title.copyWith( color: Colors.indigo,fontWeight: FontWeight.w500)),
                          Icon(
                            _showPersonalInfo
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: widget.orientation==Orientation.portrait?widget.width*0.065:widget.width*0.049,
                          ),
                        ],
                      ),
                    )),
              ),
              _showPersonalInfo?Divider(
                color: Colors.grey,
                height: 4,
              ):SizedBox(),
              _showPersonalInfo
                  ? Padding(
                    padding: const EdgeInsets.only(bottom: 8.0,left: 15,right: 15,top: 6.0),
                    child: Column(
                        children: <Widget>[
                          widget.email==''?SizedBox():_data(title:  translator.currentLanguage == "en" ?'Email:':'البريد الالكترونى: ', content: widget.email),
                         widget.phoneNumber==''?SizedBox(): _data(
                              title:  translator.currentLanguage == "en" ?'Phone Number:':'رقم الهاتف: ', content: widget.phoneNumber),
                          widget.address==''?SizedBox():_data(title:  translator.currentLanguage == "en" ?'Address:':'العنوان: ', content: widget.address),
                          widget.gender==''?SizedBox():_data(title:  translator.currentLanguage == "en" ?'Gender:':'النوع: ', content: widget.gender),
                          widget.governorate==''?SizedBox():_data(title:  translator.currentLanguage == "en" ?'Governorate:':'المحافظه: ', content: widget.governorate),
                        ],
                      ),
                  )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
