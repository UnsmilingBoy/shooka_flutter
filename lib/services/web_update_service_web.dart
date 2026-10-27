import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

// Baked in at build time via: --dart-define=BUILD_ID=<id>
// (see tool/build_web.dart which generates web/app_build.json with the
// same id, so the two halves always match). Empty on plain `flutter run`
// without --dart-define — isNewBuildAvailable() then safely returns false.
const _currentBuildId = String.fromEnvironment(
  'BUILD_ID',
  defaultValue: '',
);

/// Web implementation of [WebUpdateService] (see web_update_service.dart).
///
/// This file imports `package:web` and `dart:js_interop`, which only
/// compile for browser targets, so it is only ever included via the
/// conditional import in web_update_service.dart (never on Windows,
/// Android, iOS builds).
class WebUpdateService {
  WebUpdateService._();
  static final WebUpdateService instance = WebUpdateService._();

  /// app_build.json lives next to index.html (deployed base href), NOT
  /// relative to the current SPA route — a relative 'app_build.json' URL
  /// would resolve to e.g. /device_list/app_build.json and 404.
  Uri _appBuildJsonUri() {
    final base = Uri.base;
    var dir = base.path;
    if (!dir.endsWith('/')) {
      final i = dir.lastIndexOf('/');
      dir = i >= 0 ? dir.substring(0, i + 1) : '/';
    }
    return Uri.parse('${base.origin}${dir}app_build.json').replace(
      queryParameters: {'t': DateTime.now().millisecondsSinceEpoch.toString()},
    );
  }

  Future<String?> fetchRemoteBuildId() async {
    if (!kIsWeb) return null;
    try {
      final r = await http
          .get(
            _appBuildJsonUri(),
            headers: {
              'Cache-Control': 'no-cache, no-store, must-revalidate',
              'Pragma': 'no-cache',
            },
          )
          .timeout(const Duration(seconds: 10));
      if (r.statusCode != 200) return null;
      final data = jsonDecode(r.body);
      if (data is! Map) return null;
      final id = '${data['build_id'] ?? ''}'.trim();
      return id.isEmpty ? null : id;
    } catch (e) {
      debugPrint('WebUpdateService: app_build.json fetch failed: $e');
      return null;
    }
  }

  Future<bool> isNewBuildAvailable() async {
    if (!kIsWeb) return false;
    // Dev build without --dart-define: nothing to compare against,
    // never report an update (avoids a permanent false banner).
    if (_currentBuildId.isEmpty) return false;
    final remote = await fetchRemoteBuildId();
    if (remote == null) return false;
    return remote != _currentBuildId;
  }

  /// Unregisters ServiceWorkers, deletes CacheStorage, then hard-navigates
  /// with a cache-busting query so a stale index.html can't trap the user.
  /// `replace()` (not href=) keeps the update out of session history.
  /// Current route is preserved; only a `?v=` query is added.
  Future<void> applyUpdate() async {
    if (!kIsWeb) return;
    try {
      try {
        final regs = await web.window.navigator.serviceWorker
            .getRegistrations()
            .toDart;
        for (final reg in regs.toDart) {
          try {
            await reg.unregister().toDart;
          } catch (_) {}
        }
      } catch (_) {}
      try {
        final keys = await web.window.caches.keys().toDart;
        for (final key in keys.toDart) {
          try {
            await web.window.caches.delete(key.toDart).toDart;
          } catch (_) {}
        }
      } catch (_) {}
    } finally {
      final bust = DateTime.now().millisecondsSinceEpoch;
      try {
        final path = Uri.base.path.split('?').first;
        web.window.location.replace('$path?v=$bust');
      } catch (_) {
        try {
          web.window.location.reload();
        } catch (_) {}
      }
      // Fallback: if navigation above is somehow swallowed, force reload.
      Future.delayed(const Duration(seconds: 3), () {
        try {
          web.window.location.reload();
        } catch (_) {}
      });
    }
  }
}
