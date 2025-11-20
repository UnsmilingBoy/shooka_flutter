import 'package:flutter/material.dart';

final tabsList = [
  {
    "label": 'خانه',
    "href": ['/home'],
    "icon": Icons.home,
  },
  {
    "label": 'صفحه کاربری',
    "href": ['/profile'],
    "icon": Icons.person,
  },
  {
    'label': 'موتورخانه‌ها',
    "href": ['/device_list', '/add_device', '/device_page'],
    "icon": Icons.devices,
  },
  {
    'label': 'رویداد‌ها',
    "href": ["/events", "/add_event", '/event_page'],
    "icon": Icons.event,
  },
  {
    'label': 'لیست سازمان‌ها',
    "href": ["/organizations"],
    "icon": Icons.apartment,
  },
  {
    'label': 'لیست نما‌ها',
    "href": ["/views"],
    "icon": Icons.view_list,
  },
  {
    'label': 'لیست مکان ها',
    "href": ["/locations"],
    "icon": Icons.location_on,
  },
  // {
  //   'label': 'لیست کاربران',
  //   "href": ["/users"],
  //   "icon": Icons.group,
  // },
];
