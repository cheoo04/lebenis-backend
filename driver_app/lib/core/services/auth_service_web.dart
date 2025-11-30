// Only compiled for web (via conditional import)
import 'package:web/web.dart' as web;

String? getFromWebStorage(String key) {
  return web.window.localStorage.getItem(key);
}

Future<void> setToWebStorage(String key, String? value) async {
  if (value == null) {
    web.window.localStorage.removeItem(key);
  } else {
    web.window.localStorage.setItem(key, value);
  }
}

Future<void> clearWebStorage() async {
  web.window.localStorage.clear();
}
