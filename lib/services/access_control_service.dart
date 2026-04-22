import 'package:shooka_flutter/models/app_panel.dart';
import 'package:shooka_flutter/models/user_data_class.dart';

/// Centralised access-control logic.
///
/// Fed with the [User] object after login / profile fetch.
/// Every UI element that must be conditionally shown calls [hasAccessTo].
///
/// Rules:
///   1. If the user is an admin → full access to everything.
///   2. Otherwise, only panels whose [AppPanel.apiName] appears in the
///      backend's `accessible_panels` list are granted.
///   3. Panel names that belong to the *other* app sharing the same backend
///      are silently ignored because they will never match any [AppPanel] value.
class AccessControlService {
  bool _isAdmin = false;
  Set<String> _accessiblePanelNames = {};

  // ── Lifecycle ─────────────────────────────────────────────────────────

  /// Call after a successful profile / login fetch.
  void updateFromUser(User user) {
    _isAdmin = user.isAdmin;
    _accessiblePanelNames = user.userRole.accessiblePanels
        .map((p) => p.name)
        .toSet();
  }

  /// Call on logout to revoke all permissions.
  void clear() {
    _isAdmin = false;
    _accessiblePanelNames = {};
  }

  // ── Queries ───────────────────────────────────────────────────────────

  bool get isAdmin => _isAdmin;

  /// Returns `true` when the current user may see / use [panel].
  bool hasAccessTo(AppPanel panel) {
    if (_isAdmin) return true;
    return _accessiblePanelNames.contains(panel.apiName);
  }

  /// Returns `true` when the current user may see / use **any** of [panels].
  bool hasAccessToAny(List<AppPanel> panels) {
    if (_isAdmin) return true;
    return panels.any((p) => _accessiblePanelNames.contains(p.apiName));
  }
}
