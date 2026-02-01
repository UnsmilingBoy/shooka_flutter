import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';

/// Shows a connection error dialog with retry option
Future<void> showConnectionErrorDialog({
  required BuildContext context,
  required String errorMessage,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(
              Icons.wifi_off_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 28,
            ),
            SizedBox(width: 12),
            Text('خطای اتصال'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(errorMessage, style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: 8),
            Text(
              'لطفا اتصال اینترنت خود را بررسی کنید و دوباره تلاش کنید',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ContainerButton(
            fillWidth: true,
            color: Theme.of(context).primaryColor,
            borderRadius: 10,
            onPressed: () => Navigator.of(context).pop(),
            child: Text('باشه'),
          ),
        ],
      ),
    ),
  );
}

/// Shows a simple connection error snackbar (alternative to dialog)
void showConnectionErrorSnackbar({
  required BuildContext context,
  required String errorMessage,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Text(errorMessage, style: TextStyle(fontFamily: 'Vazir')),
          ),
        ],
      ),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 4),
      action: SnackBarAction(
        label: 'باشه',
        textColor: Colors.white,
        onPressed: () {},
      ),
    ),
  );
}
