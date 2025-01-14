import 'dart:io';

import 'package:ai_buddy/core/util/btnutils.dart';
import 'package:ai_buddy/core/util/constants.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:url_launcher/url_launcher.dart';

class SubscriptionInfoScreen extends StatefulWidget {
  const SubscriptionInfoScreen({required this.userData, super.key});
  final Map<String, dynamic> userData;

  @override
  State<SubscriptionInfoScreen> createState() => _SubscriptionInfoScreenState();
}

class _SubscriptionInfoScreenState extends State<SubscriptionInfoScreen> {
  Future<void> _launchWhatsApp() async {
    const contact = '+91-8818888870';
    const androidUrl =
        'whatsapp://send?phone=$contact&text=Hi, I would like to upgrade my 9Roof AI account to Pro.';
    final iosUrl =
        "https://wa.me/$contact?text=${Uri.parse('Hi, I would like to upgrade my 9Roof AI account to Pro.')}";

    try {
      if (Platform.isIOS) {
        await launchUrl(Uri.parse(iosUrl));
      } else {
        await launchUrl(Uri.parse(androidUrl));
      }
    } on Exception {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // ignore: use_build_context_synchronously
          backgroundColor: Theme.of(context).colorScheme.onSurface,
          content: const Text('Unable to open WhatsApp'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPro = widget.userData['is_pro'] as bool;
    final creditsUsed = widget.userData['credits_used'] as int;
    final credits_remaining = maxCredits - creditsUsed;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 50),
                  Text(
                    'Your Subscription',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  buildCloseButton(context),
                ],
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/roofbot.png',
                            height: 140,
                            width: 140,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              bottom: 15,
                            ),
                            child: Text(
                                isPro
                                    ? 'Your subscription is active'
                                    : 'You have $credits_remaining credits left',
                                textAlign: TextAlign.center,
                                style:
                                    Theme.of(context).textTheme.headlineSmall!),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    isPro
                        ? 'You have unlimited access to all features'
                        : 'Upgrade to Pro for unlimited access',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: buildElevatedButton(
                isPro ? 'Close' : 'Subscribe Now',
                () {
                  if (!isPro) {
                    _launchWhatsApp();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                context,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
