import 'package:flutter/material.dart';

class CustomLoader extends StatelessWidget {
  const CustomLoader({
    super.key,
    this.color,
    this.radius = 15,
    this.padding = 5,
  });
  static const id = 'CustomLoader';

  final Color? color;
  final double radius;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: SizedBox(
          height: radius * 2,
          width: radius * 2,
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ),
    );
  }
}
