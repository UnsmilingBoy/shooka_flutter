// Facade for stale-web-build detection and forced reload.
//
// Implemented with `package:web`/`dart:js_interop`, which only compile for
// browser targets. The conditional export below picks the real
// implementation on web (where `dart:html` is available) and a no-op stub
// everywhere else, so native builds never compile the web-only code.
export 'web_update_service_stub.dart'
    if (dart.library.html) 'web_update_service_web.dart';
