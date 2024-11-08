import 'package:ai_buddy/core/navigation/route.dart';
import 'package:ai_buddy/core/util/utils.dart';
import 'package:ai_buddy/feature/chat/provider/message_provider.dart';
import 'package:ai_buddy/feature/hive/model/search_item/search_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchGridView extends ConsumerStatefulWidget {
  const SearchGridView({super.key});

  @override
  ConsumerState<SearchGridView> createState() => _SearchGridViewState();
}

class _SearchGridViewState extends ConsumerState<SearchGridView> {
  late List<SearchItem> searchItems;

  @override
  void didChangeDependencies() {
    searchItems = getFeaturedSearches();
    super.didChangeDependencies();
  }

  Widget buildGridTile(SearchItem option, BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppRoute.home.push(context);

        ref
            .read(messageListProvider.notifier)
            .handleSendPressed(text: option.title);
      },
      child: Chip(
        elevation: 12,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.search,
              size: 20,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              option.title,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 12,
                  ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(30),
            right: Radius.circular(30),
          ),
        ),
      ),
    );
  }

  SizedBox _buildEmotionGridView(
    BuildContext context,
    WidgetRef ref,
    List<SearchItem> items,
  ) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: items.map((item) => buildGridTile(item, context)).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildEmotionGridView(context, ref, searchItems.sublist(0, 5)),
          _buildEmotionGridView(context, ref, searchItems.sublist(5, 10)),
          _buildEmotionGridView(context, ref, searchItems.sublist(10, 15)),
        ],
      ),
    );
  }
}
