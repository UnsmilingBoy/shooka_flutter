/// Defines all panels and features in this app that are subject to access control.
///
/// The [apiName] must match the `name` field returned from the backend's
/// `accessible_panels` list. Panels from the other app (that share the same
/// backend) are simply ignored because they won't match any value here.
enum AppPanel {
  deviceList('device_list'),
  eventList('event_list'),
  orgList('org_list'),
  locList('loc_list'),
  exportFunctionality('export_functionality'),
  deviceStatusFunctionality('device_status_functionality'),
  addDeviceFunctionality('add_device_functionality'),
  addEventFunctionality('add_event_functionality'),
  accounting('accountant_panel'); // ← add this

  final String apiName;
  const AppPanel(this.apiName);
}
