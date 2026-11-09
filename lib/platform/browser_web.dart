import 'dart:ui_web' as ui_web;

import 'package:web/web.dart' as web;

void setPageMeta({required String title, String? description}) {
  web.document.title = title;
  _meta('property', 'og:title', title);
  _meta('name', 'twitter:title', title);
  if (description != null) {
    _meta('name', 'description', description);
    _meta('property', 'og:description', description);
    _meta('name', 'twitter:description', description);
  }
}

void _meta(String attr, String key, String content) {
  var el = web.document.head?.querySelector('meta[$attr="$key"]');
  if (el == null) {
    el = web.document.createElement('meta')..setAttribute(attr, key);
    web.document.head?.append(el);
  }
  el.setAttribute('content', content);
}

Future<void> downloadAsset(String assetKey, String fileName) async {
  final url = ui_web.assetManager.getAssetUrl(assetKey);
  final a = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = fileName
    ..target = '_blank'
    ..rel = 'noopener';
  web.document.body?.append(a);
  a.click();
  a.remove();
}

void removeSplash() {
  final splash = web.document.getElementById('splash');
  if (splash == null) return;
  splash.classList.add('done');
  Future<void>.delayed(
    const Duration(milliseconds: 400),
    () => splash.remove(),
  );
}

void toggleFullscreen() {
  if (web.document.fullscreenElement != null) {
    web.document.exitFullscreen();
  } else {
    web.document.documentElement?.requestFullscreen();
  }
}
