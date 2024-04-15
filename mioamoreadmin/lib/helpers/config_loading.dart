import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

void configLoading({
  required bool isDarkMode,
  required foregroundColor,
  required backgroundColor,
}) {
  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorColor = foregroundColor
    ..backgroundColor = backgroundColor
    ..textColor = foregroundColor
    ..indicatorType = EasyLoadingIndicatorType.circle
    ..progressColor = foregroundColor
    ..maskType = EasyLoadingMaskType.black
    ..animationStyle = EasyLoadingAnimationStyle.scale
    ..animationDuration = const Duration(milliseconds: 200)
    ..toastPosition = EasyLoadingToastPosition.bottom
    ..radius = 8
    ..boxShadow = const [
      BoxShadow(
        color: Colors.black12,
        offset: Offset(0, 4),
        blurRadius: 10,
        spreadRadius: 2,
      )
    ]
    ..dismissOnTap = false;
}
