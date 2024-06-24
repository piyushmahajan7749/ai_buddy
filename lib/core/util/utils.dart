import 'dart:collection';

import 'package:ai_buddy/feature/hive/model/search_item/search_item.dart';
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

List<SearchItem> getFeaturedSearches() {
  final list = allSearchesStatic.map((item) {
    final SearchItem obj = item;
    return obj;
  }).toList();
  return list;
}

UnmodifiableListView<SearchItem> get allSearchesStatic => UnmodifiableListView([
      SearchItem(
        title: 'Furnished office spaces',
        id: 'officespaces',
        searchTerm: '',
      ),
      SearchItem(
        title: '2 bhk Furnished flats',
        id: 'bhk3',
        searchTerm: '',
      ),
      SearchItem(
        title: 'Studio apartments',
        id: 'bhk3',
        searchTerm: '',
      ),
      SearchItem(
        title: '1 bhk Flats for rent',
        id: 'bhk3',
        searchTerm: '',
      ),
      SearchItem(
        title: '1RK flats',
        id: 'bhk3',
        searchTerm: '',
      ),
      SearchItem(
        title: 'Plots for sale',
        id: 'bhk1',
        searchTerm: '',
      ),
      SearchItem(
        title: 'Plots required',
        id: 'officespaces',
        searchTerm: '',
      ),
      SearchItem(
        title: 'Plots and houses in ujjain road',
        id: 'bhk3',
        searchTerm: '',
      ),
      SearchItem(
        title: 'Flats for sale in 140',
        id: 'bhk1',
        searchTerm: '',
      ),
      SearchItem(
        title: 'Hostels in Vijay nagar',
        id: 'bhk1',
        searchTerm: '',
      ),
      SearchItem(
        title: 'Flats for sale in under 60 lakhs',
        id: 'officespaces',
        searchTerm: '',
      ),
      SearchItem(
        title: 'Plots and houses in bypass',
        id: 'bhk3',
        searchTerm: '',
      ),
      SearchItem(
        title: 'Flats for rent in Rajendra Nagar',
        id: 'bhk3',
        searchTerm: '',
      ),
      SearchItem(
        title: 'Commercial plot for sale',
        id: 'bhk1',
        searchTerm: '',
      ),
      SearchItem(
        title: 'Commercial shop for rent',
        id: 'bhk1',
        searchTerm: '',
      ),
    ]);
