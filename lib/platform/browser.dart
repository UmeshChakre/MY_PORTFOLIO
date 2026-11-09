import 'package:url_launcher/url_launcher.dart';

import 'browser_stub.dart'
    if (dart.library.js_interop) 'browser_web.dart'
    as impl;

/// Thin wrapper over browser-only APIs, with no-op fallbacks so tests and
/// other platforms still compile.
abstract final class Browser {
  /// Updates `<title>` and the description / Open Graph meta tags.
  static void setPageMeta({required String title, String? description}) =>
      impl.setPageMeta(title: title, description: description);

  /// Downloads a bundled Flutter asset under [fileName].
  static Future<void> downloadAsset(String assetKey, String fileName) =>
      impl.downloadAsset(assetKey, fileName);

  /// Enters or leaves browser fullscreen.
  static void toggleFullscreen() => impl.toggleFullscreen();

  /// Hides the HTML loading screen from web/index.html.
  static void removeSplash() => impl.removeSplash();

  static Future<void> open(String url) async {
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: url.startsWith('http') ? '_blank' : '_self',
    );
  }

  static Future<void> email(String to, {String? subject, String? body}) {
    final query = [
      if (subject != null) 'subject=${Uri.encodeComponent(subject)}',
      if (body != null) 'body=${Uri.encodeComponent(body)}',
    ].join('&');
    return open('mailto:$to${query.isEmpty ? '' : '?$query'}');
  }
}
