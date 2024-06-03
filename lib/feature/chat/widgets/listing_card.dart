import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ListingCard extends StatelessWidget {
  final String senderName;
  final String? senderNumber;
  final String message;
  final String dateOfMessage;

  const ListingCard({
    Key? key,
    required this.senderName,
    required this.senderNumber,
    required this.message,
    required this.dateOfMessage,
  }) : super(key: key);

  void _launchCaller(String number) async {
    final url = 'tel:$number';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchWhatsApp(String number) async {
    final url = 'https://wa.me/$number';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              senderName,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              message,
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              dateOfMessage,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (senderNumber != null) ...[
                  IconButton(
                    icon: Icon(Icons.call),
                    onPressed: () => _launchCaller(senderNumber!),
                  ),
                  IconButton(
                    icon: Icon(Icons.message),
                    onPressed: () => _launchWhatsApp(senderNumber!),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
