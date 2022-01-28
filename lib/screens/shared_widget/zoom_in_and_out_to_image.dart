import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
class ShowImage extends StatelessWidget {
  final String title;
  final String imgUrl;
  final bool isImgUrlAsset;
  final File imageFile;

  ShowImage({this.imageFile,this.title,this.imgUrl,this.isImgUrlAsset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size:
              MediaQuery
                  .of(context)
                  .orientation == Orientation.portrait
                  ? MediaQuery
                  .of(context)
                  .size
                  .width * 0.05
                  : MediaQuery
                  .of(context)
                  .size
                  .width * 0.035,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        centerTitle: true,
        title: Text(title,style: TextStyle(
            fontSize: MediaQuery
                .of(context)
              .orientation==Orientation.portrait?MediaQuery
                .of(context)
                .size.width * 0.04:MediaQuery
                .of(context)
                .size.width * 0.03,
            color: Colors.white,
            fontWeight: FontWeight.bold),),

       ),
      body: Container(
          child: PhotoView(
            imageProvider: imageFile != null ?FileImage(imageFile) :isImgUrlAsset?AssetImage(imgUrl):NetworkImage(imgUrl),
          )
      ),
    );
  }
}
