import 'dart:async';

import 'package:flutter/material.dart' hide ModalBottomSheetRoute;

typedef NextCallback = void Function({Duration delay});
// ignore: lines_longer_than_80_chars
typedef SequenceItemBuilder = Widget Function(
  NextCallback next,
  NextCallback? previous,
);

class AnimatedSwitcherSequenceController with ChangeNotifier {
  void skipToNext() {
    notifyListeners();
  }
}

class AnimatedSwitcherSequence extends StatefulWidget {
  AnimatedSwitcherSequence({
    required this.builders,
    required this.controller,
    required this.beforeLoop,
    super.key,
  }) {
    if (builders.length < 2) {
      throw FlutterError(
        // ignore: lines_longer_than_80_chars
        'AnimatedWidgetSequence must be passed at least 2 builder functions in the builders property.',
      );
    }
  }

  /// There must be at least 2 builder functions.
  final List<SequenceItemBuilder> builders;

  final AnimatedSwitcherSequenceController controller;

  final Function beforeLoop;

  @override
  // ignore: library_private_types_in_public_api
  _AnimatedSwitcherSequenceState createState() =>
      _AnimatedSwitcherSequenceState();
}

class _AnimatedSwitcherSequenceState extends State<AnimatedSwitcherSequence> {
  int currentWidget = 0;

  late Timer delayTimer = Timer(const Duration(seconds: 5), () {});

  late AnimatedSwitcherSequenceController controller;

  void _advanceWidget() {
    if (currentWidget == widget.builders.length - 1) {
      widget.beforeLoop.call();
    }

    setState(() {
      currentWidget = (currentWidget + 1) % widget.builders.length;
    });
  }

  void _goBackWidget() {
    setState(() {
      currentWidget = (currentWidget - 1) % widget.builders.length;
    });
  }

  void next({Duration? delay}) {
    if (delay == null) {
      delayTimer.cancel();
      _advanceWidget();
      return;
    }

    // ignore: unnecessary_null_comparison
    if (delayTimer != null) {
      delayTimer.cancel();
    }

    delayTimer = Timer(delay, _advanceWidget);
  }

  void previous({Duration? delay}) {
    if (delay == null) {
      delayTimer.cancel();
      _goBackWidget();
      return;
    }

    // ignore: unnecessary_null_comparison
    if (delayTimer != null) {
      delayTimer.cancel();
    }

    delayTimer = Timer(delay, _goBackWidget);
  }

  @override
  void initState() {
    super.initState();

    controller = widget.controller;
    controller
      ..addListener(next)
      ..addListener(previous);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(seconds: 1),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: widget.builders[currentWidget](next, previous),
    );
  }

  @override
  void dispose() {
    delayTimer.cancel();
    controller
      ..removeListener(next)
      ..removeListener(previous);
    super.dispose();
  }
}
