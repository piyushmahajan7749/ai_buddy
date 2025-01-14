import 'package:ai_buddy/core/ui/widget/animated_widget_sequence.dart';
import 'package:ai_buddy/core/ui/widget/reminderscreen.dart';
import 'package:ai_buddy/core/util/btnutils.dart';
import 'package:ai_buddy/feature/onboarding/constants.dart';
import 'package:ai_buddy/feature/onboarding/onboardingutils.dart';
import 'package:ai_buddy/feature/welcome/login.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:go_router/go_router.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late Material materialButton;
  late int index;
  int roundsElapsed = 0;
  bool showDoneButton = false;

  AnimatedSwitcherSequenceController animatedSwitcherSequenceController =
      AnimatedSwitcherSequenceController();

  @override
  void initState() {
    super.initState();
    index = 0;
  }

  void showReminderModal() {
    showBarModalBottomSheet<void>(
      duration: const Duration(milliseconds: 500),
      animationCurve: Curves.easeIn,
      context: context,
      isDismissible: false,
      barrierColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      builder: (context) => SizedBox(
        height: 80.h,
        child: const ReminderScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: showDoneButton
          ? buildTextFloatingButton(
              () async {
                await Navigator.pushReplacement(
                  context,
                  PageTransition<dynamic>(
                    type: PageTransitionType.bottomToTop,
                    child: const LoginScreen(showClose: false),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              "Let's go!",
              'info-done',
              context,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: AnimatedSwitcherSequence(
        controller: animatedSwitcherSequenceController,
        beforeLoop: () async {
          roundsElapsed++;
          if (roundsElapsed >= 1) {
            GoRouter.of(context).go('/login');
          }
        },
        builders: [
          (next, previous) {
            return buildInfoPage(
              introSteps[0].title,
              introSteps[0].description,
              next,
              previous!,
              context,
              1,
            );
          },
          (next, previous) {
            return buildInfoPage(
              introSteps[1].title,
              introSteps[1].description,
              next,
              previous!,
              context,
              2,
            );
          },
          (next, previous) {
            return buildInfoPage(
              introSteps[2].title,
              introSteps[2].description,
              next,
              previous!,
              context,
              3,
            );
          },
        ],
      ),
    );
  }
}
