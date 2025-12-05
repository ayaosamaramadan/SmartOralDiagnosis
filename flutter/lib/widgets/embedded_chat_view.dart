// Conditional export: web implementation when `dart:html` is available, otherwise stub (native)
export 'embedded_chat_view_stub.dart'
    if (dart.library.html) 'embedded_chat_view_web.dart';
