/// Native-platform stub of WebUpdateService (see web_update_service.dart).
///
/// Stale-build detection / forced-reload only applies to the deployed web
/// build, so on Windows/Android/iOS every method is a safe no-op. This file
/// must not import `package:web` or `dart:js_interop`, since those do not
/// compile for native targets.
class WebUpdateService {
  WebUpdateService._();
  static final WebUpdateService instance = WebUpdateService._();

  Future<String?> fetchRemoteBuildId() async => null;

  Future<bool> isNewBuildAvailable() async => false;

  Future<void> applyUpdate() async {}
}
