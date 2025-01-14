import 'package:ai_buddy/core/app/style.dart';
import 'package:ai_buddy/core/navigation/router.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:sizer/sizer.dart';

class RoofAI extends StatelessWidget {
  const RoofAI({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp.router(
            title: '9Roof AI',
            theme: darkTheme,
            debugShowCheckedModeBanner: false,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
