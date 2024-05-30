import 'package:ai_buddy/feature/chat/chat_page.dart';
import 'package:ai_buddy/feature/home/home_page.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:line_icons/line_icons.dart';

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
    const HomePage(),
    const ChatPage(),
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

  ConvexAppBar buildConvexAppBar() {
    const double width = 26;
    const double height = 50;
    return ConvexAppBar(
      height: height,
      style: TabStyle.react,
      backgroundColor: Theme.of(context).colorScheme.background,
      color: Theme.of(context).colorScheme.onSurface,
      activeColor: Theme.of(context).colorScheme.secondary,
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.surface,
      items: [
        TabItem(
          title: 'Home',
          icon: Icon(
            LineIcons.home,
            size: width,
            color: Theme.of(context).colorScheme.secondary,
          ),
          isIconBlend: true,
        ),
        TabItem(
          title: 'Chat',
          icon: Icon(
            Icons.inbox,
            size: width,
            color: Theme.of(context).colorScheme.secondary,
          ),
          isIconBlend: true,
        ),
      ],
      initialActiveIndex: _page,
      onTap: (i) => {
        setState(() {
          _page = i;
        }),
      },
    );
  }
}
