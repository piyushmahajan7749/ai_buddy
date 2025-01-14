import 'package:ai_buddy/core/util/btnutils.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:sizer/sizer.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

Row buildProgressHeader(
    BuildContext context, Function previous, int step, int totalSteps) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 10),
        child: buildIconButton(
          context,
          Icons.arrow_back_ios,
          () => previous(),
        ),
      ),
      SizedBox(
        width: 60.w,
        child: StepProgressIndicator(
          totalSteps: totalSteps,
          currentStep: step,
          size: 10,
          padding: 0,
          selectedColor: Theme.of(context).colorScheme.primary,
          unselectedColor: Theme.of(context).colorScheme.onSurface,
          roundedEdges: const Radius.circular(20),
        ),
      ),
      const SizedBox(width: 40),
    ],
  );
}

SafeArea buildInfoPage(
  String title,
  String desc,
  Function next,
  Function previous,
  BuildContext context,
  int step,
) {
  return SafeArea(
    child: Column(
      children: [
        SizedBox(
          height: 5.h,
          child: buildProgressHeader(context, previous, step, 3),
        ),
        SizedBox(
          height: 82.h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(30),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
              SizedBox(
                height: 30.h,
                child: Image.asset('assets/images/onboarding$step.jpg'),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Text(
                      desc,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 20,
                          ),
                    ),
                  ),
                  buildOutlinedButton('Tap to continue', next, context),
                  const SizedBox(height: 40),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
