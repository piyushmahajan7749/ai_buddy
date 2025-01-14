import 'package:ai_buddy/core/util/btnutils.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:line_icons/line_icons.dart';
import 'package:sizer/sizer.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.w,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildSharebutton(context),
            buildRoundedIconButton(
              context,
              () {
                // showSubscriptionScreen(context);
              },
              LineIcons.crown,
            ),
          ],
        ),
      ),
    );
  }
}
