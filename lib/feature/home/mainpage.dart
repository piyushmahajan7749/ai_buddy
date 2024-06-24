import 'package:ai_buddy/feature/chat/chat_page.dart';
import 'package:ai_buddy/feature/home/home_page.dart';
import 'package:ai_buddy/feature/home/widgets/settings.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;

class MainPage extends StatefulWidget {
  const MainPage({
    required this.page,
    super.key,
  });
  final int page;

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _page = 1;
  final _pageOptions = [
    const ChatPage(),
    const ChatHistoryPage(),
    const Preferences(),
  ];

  @override
  void initState() {
    super.initState();
    _page = widget.page;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageOptions[_page],
      bottomNavigationBar: buildConvexAppBar(),
    );
  }

  FlashyTabBar buildConvexAppBar() {
    const double width = 26;
    return FlashyTabBar(
      animationCurve: Curves.linear,
      selectedIndex: _page,
      iconSize: 30,
      showElevation: false,
      backgroundColor: Theme.of(context).colorScheme.background,
      // color: Theme.of(context).colorScheme.onSurface,
      // activeColor: Theme.of(context).colorScheme.secondary,
      // elevation: 4,
      // shadowColor: Theme.of(context).colorScheme.surface,
      items: [
        FlashyTabBarItem(
          title: Text(
            'Home',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          icon: Icon(
            CupertinoIcons.home,
            size: width,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        FlashyTabBarItem(
          title: Text(
            'AI chat',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          icon: Icon(
            CupertinoIcons.time,
            size: width,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        FlashyTabBarItem(
          title: Text(
            'You',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          icon: Icon(
            CupertinoIcons.profile_circled,
            size: width,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],

      onItemSelected: (i) => {
        setState(() {
          _page = i;
        }),
      },
    );
  }
}
