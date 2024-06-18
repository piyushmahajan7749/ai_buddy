import 'package:url_launcher/url_launcher.dart';

Future<void> launchInWebViewOrVC(Uri url) async {
  if (!await launchUrl(
    url,
    mode: LaunchMode.inAppWebView,
    webViewConfiguration: const WebViewConfiguration(
      headers: <String, String>{'my_header_key': 'my_header_value'},
    ),
  )) {
    // ignore: only_throw_errors
    throw 'Could not launch $url';
  }
}

String? extractPhoneNumber(String text) {
  final phonePattern =
      RegExp(r'\b\d{10}\b'); // Simple pattern for 10-digit phone numbers
  final match = phonePattern.firstMatch(text);
  return match?.group(0);
}
