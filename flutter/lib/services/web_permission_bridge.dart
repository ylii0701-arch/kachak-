// Conditional export for browser permission helpers.
// The web implementation uses browser APIs, while the stub provides
// safe defaults on non-web platforms.
export 'web_permission_bridge_stub.dart'
    if (dart.library.html) 'web_permission_bridge_web.dart';
