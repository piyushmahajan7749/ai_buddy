import 'package:ai_buddy/core/database/dbuser.dart';
import 'package:ai_buddy/core/ui/modals/invitefriends.dart';
import 'package:ai_buddy/core/ui/modals/subscriptioninfo.dart';
import 'package:ai_buddy/core/util/auth.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:line_icons/line_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sizer/sizer.dart';

IconButton buildCloseButton(BuildContext context) {
  return IconButton(
    icon: Icon(
      Icons.close_rounded,
      size: Device.screenType == ScreenType.mobile ? 8.w : 4.w,
      color: Theme.of(context).colorScheme.primary,
    ),
    onPressed: () {
      Navigator.pop(context);
    },
  );
}

IconButton buildIconButton(
  BuildContext context,
  IconData icon,
  Function onPress,
) {
  return IconButton(
    icon: Icon(
      icon,
      size: Device.screenType == ScreenType.mobile ? 5.w : 3.w,
      color: Theme.of(context).colorScheme.primary,
    ),
    onPressed: () => onPress(),
  );
}

FloatingActionButton buildIconFloatingButton(
  BuildContext context,
  Function onpress,
  String hero,
  Icon icon,
) {
  return FloatingActionButton(
    elevation: 1,
    heroTag: hero,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    onPressed: () => onpress(),
    child: icon,
  );
}

FloatingActionButton buildTextFloatingButton(
  Function onpress,
  String label,
  String hero,
  BuildContext context,
) {
  return FloatingActionButton.extended(
    backgroundColor: Theme.of(context).colorScheme.primary,
    label: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
      ),
    ),
    heroTag: hero,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    onPressed: () => onpress(),
  );
}

FloatingActionButton buildTextOutlinedFloatingButton(
  Function onpress,
  String label,
  String hero,
  BuildContext context,
) {
  return FloatingActionButton.extended(
    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    label: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
      ),
    ),
    elevation: 2,
    heroTag: hero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    onPressed: () => onpress(),
  );
}

Widget buildRoundedIconButton(
  BuildContext context,
  Function onPress,
  IconData icon,
) {
  return Card(
    elevation: 2,
    child: Container(
      width: Device.screenType == ScreenType.mobile ? 50 : 80,
      height: Device.screenType == ScreenType.mobile ? 50 : 80,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: IconButton(
        onPressed: () => onPress(),
        icon: Icon(
          icon,
          size: Device.screenType == ScreenType.mobile ? 25 : 40,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    ),
  );
}

Widget buildNextButton(Function next, BuildContext context) {
  return buildOutlinedButton('Next', next, context);
}

OutlinedButton buildOutlinedIconButton(
  Function next,
  String text,
  IconData icon,
  BuildContext context,
) {
  return OutlinedButton(
    onPressed: () {
      next();
    },
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(15),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Icon(
          icon,
          size: Device.screenType == ScreenType.mobile ? 12.sp : 6.sp,
        ),
      ],
    ),
  );
}

Widget buildOutlinedButton(
  String label,
  Function onPressed,
  BuildContext context,
) {
  return OutlinedButton(
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
      ),
    ),
    onPressed: () => onPressed(),
    child: Text(
      label,
      style: Theme.of(context).textTheme.bodyLarge,
    ),
  );
}

Widget buildElevatedButton(
  String label,
  Function onPressed,
  BuildContext context,
) {
  return ElevatedButton(
    style: TextButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.surfaceBright,
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
      ),
    ),
    onPressed: () => onPressed(),
    child: Text(
      label,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontSize: 20,
            color: Theme.of(context).colorScheme.surface,
          ),
    ),
  );
}

Widget buildSharebutton(BuildContext context) {
  return buildRoundedIconButton(
    context,
    () {
      showBarModalBottomSheet<void>(
        duration: const Duration(milliseconds: 500),
        animationCurve: Curves.easeIn,
        context: context,
        isDismissible: false,
        barrierColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        builder: (context) => const InviteFriendsScreen(),
      );
    },
    LineIcons.gift,
  );
}

Future<Widget> buildSubscriptionbutton(BuildContext context) async {
  final String? userId = AuthService().getCurrentUserId();

  final userData = await DbServiceUser(uid: userId!).getUserData();

  return buildRoundedIconButton(
    context,
    () {
      showBarModalBottomSheet<void>(
        duration: const Duration(milliseconds: 500),
        animationCurve: Curves.easeIn,
        context: context,
        isDismissible: false,
        barrierColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        builder: (context) =>
            SubscriptionInfoScreen(isPro: userData['is_pro'] as bool),
      );
    },
    LineIcons.crown,
  );
}
