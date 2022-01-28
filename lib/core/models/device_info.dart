import 'package:flutter/cupertino.dart';
import 'package:helpme/core/enums/device_type.dart';



class DeviceInfo {
  final Orientation orientation;
  final DeviceType deviceType;
  final double screenWidth;
  final double screenHeight;
  final TextStyle title;
  final TextStyle subTitle;
  final double defaultVerticalPadding;
  final double defaultHorizontalPadding;
  final TextStyle titleButton;
  DeviceInfo(
      {this.orientation,
      this.deviceType,
      this.screenWidth,
      this.screenHeight,
        this.title,
        this.subTitle,
        this.titleButton,
        this.defaultVerticalPadding,
        this.defaultHorizontalPadding,
      });
}
