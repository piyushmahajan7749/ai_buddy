import 'package:ai_buddy/core/util/btnutils.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:share_plus/share_plus.dart';

class InviteFriendsScreen extends StatelessWidget {
  const InviteFriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    'Invite friends',
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
                              'FREE TRIAL PASS',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall!,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Send your colleagues a free pass',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: buildElevatedButton(
                'Share 9Roof AI',
                () {
                  Share.share(
                    'I have been using 9Roof AI to search for properties finding it very helpful.\n\nI wanted to share this guest pass with you, they are offering 1 month free trial for new users, check it out here:\n\nhttps://www.9roof.com/',
                    subject: '9Roof AI Free Trial Offer',
                  );
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
