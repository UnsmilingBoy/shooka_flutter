import 'package:flutter/material.dart';
import 'package:shooka_flutter/models/app_panel.dart';

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
    "href": [
      '/device_list',
      '/add_device',
      '/device_page',
      '/rejected_devices',
      '/suspended_devices',
    ],
    "icon": Icons.devices,
    "panel": AppPanel.deviceList,
    "children": [
      {
        'label': 'همه موتورخانه‌ها',
        "href": ['/device_list', '/add_device', '/device_page'],
        "icon": Icons.list,
      },
      {
        'label': 'در حال بررسی',
        "href": ['/suspended_devices'],
        "icon": Icons.hourglass_empty,
      },
      {
        'label': 'موتورخانه های رد شده',
        "href": ['/rejected_devices'],
        "icon": Icons.cancel_outlined,
      },
    ],
  },
  {
    'label': 'رویداد‌ها',
    "href": [
      '/events',
      '/add_event',
      '/event_page',
      '/software_support',
      '/software_support_event_page',
    ],
    "children": [
      {
        'label': 'رویداد های نصاب ها',
        "href": ['/events', '/add_event', '/event_page'],
        "icon": Icons.list,
      },
      {
        'label': 'پشتیبانی نرم افزاری',
        "href": ['/software_support', '/software_support_event_page'],
        "icon": Icons.hourglass_empty,
      },
    ],
    "icon": Icons.event,
    "panel": AppPanel.eventList,
  },
  {
    'label': 'لیست سازمان‌ها',
    "href": ["/organizations"],
    "icon": Icons.apartment,
    "panel": AppPanel.orgList,
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
    "panel": AppPanel.locList,
  },
  {
    'label': 'پنل حسابداری',
    "href": ["/accounting"],
    "icon": Icons.account_balance,
    "panel": AppPanel.accounting,
  },
  // {
  //   'label': 'لیست کاربران',
  //   "href": ["/users"],
  //   "icon": Icons.group,
  // },
];
