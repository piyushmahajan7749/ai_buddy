import 'package:ai_buddy/core/navigation/route.dart';
import 'package:ai_buddy/feature/chat/provider/message_provider.dart';
import 'package:ai_buddy/feature/hive/hive.dart';
import 'package:ai_buddy/feature/hive/model/search_item/search_item.dart';
import 'package:ai_buddy/feature/home/provider/chat_bot_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class SearchGridView extends ConsumerWidget {
  const SearchGridView({
    required this.featuredSearches,
    super.key,
  });

  final List<SearchItem> featuredSearches;

  Widget buildGridTile(SearchItem option, BuildContext context) {
    return Chip(
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
      backgroundColor: Theme.of(context).colorScheme.onBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(30),
          right: Radius.circular(30),
        ),
      ),
    );
  }

  Widget buildEmotionGridItem(
    BuildContext context,
    SearchItem option,
  ) {
    return buildGridTile(option, context);
  }

  Padding _buildEmotionGridView(
    BuildContext context,
    WidgetRef ref,
    List<ChatBot> chatBotsList,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        key: Key(const Uuid().v4()),
        itemCount: featuredSearches.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, i) {
          return Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                AppRoute.chat.push(context);
                ref
                    .read(messageListProvider.notifier)
                    .handleSendPressed(text: featuredSearches[i].title);
              },
              child: buildEmotionGridItem(context, featuredSearches[i]),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatBotsList = ref.watch(chatBotListProvider);

    return SingleChildScrollView(
      child: _buildEmotionGridView(context, ref, chatBotsList),
    );
  }
}
