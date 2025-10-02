import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

filledSuccessToast({required String title}) {
  return toastTemplate(
    title: title,
    type: ToastificationType.success,
    style: ToastificationStyle.fillColored,
  );
}

filledErrorToast({required String title}) {
  return toastTemplate(
    title: title,
    type: ToastificationType.error,
    style: ToastificationStyle.fillColored,
  );
}

flatErrorToast({required String title}) {
  return toastTemplate(
    title: title,
    type: ToastificationType.error,
    style: ToastificationStyle.flat,
    backgroundColor: Colors.red.shade100,
    border: BorderSide(color: Colors.red.shade700),
  );
}

toastTemplate({
  required String title,
  required ToastificationType type,
  required ToastificationStyle style,
  Color? backgroundColor,
  BorderSide? border,
  TextStyle? textStyle,
}) {
  return toastification.show(
    type: type,
    title: Text(title, style: textStyle),
    alignment: Alignment.bottomCenter,
    backgroundColor: backgroundColor,
    borderSide: border,
    direction: TextDirection.rtl,
    style: style,
    autoCloseDuration: const Duration(seconds: 4),
  );
}
