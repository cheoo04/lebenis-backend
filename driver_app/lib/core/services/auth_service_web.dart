// Only compiled for web (via conditional import)
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

String? getFromWebStorage(String key) {
  return html.window.localStorage[key];
}

Future<void> setToWebStorage(String key, String? value) async {
  if (value == null) {
    html.window.localStorage.remove(key);
  } else {
    html.window.localStorage[key] = value;
  }
}

Future<void> clearWebStorage() async {
  html.window.localStorage.clear();
}
