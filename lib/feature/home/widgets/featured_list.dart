import 'package:ai_buddy/core/util/utils.dart';
import 'package:ai_buddy/feature/hive/model/search_item/search_item.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_horizontal_featured_list/flutter_horizontal_featured_list.dart';

class FeaturedSearchesGrid extends StatefulWidget {
  const FeaturedSearchesGrid({
    required this.handleSelect,
    super.key,
  });
  final Function handleSelect;

  @override
  State<FeaturedSearchesGrid> createState() => _SinglesActivitiesGridState();
}

class _SinglesActivitiesGridState extends State<FeaturedSearchesGrid> {
  late List<SearchItem> featuredSearches;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    featuredSearches = getFeaturedSearches();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FilteredActivities(
      searchItems: featuredSearches,
      category: 'Featured Searches',
      handleSelect: widget.handleSelect,
    );
  }
}

class FilteredActivities extends StatelessWidget {
  const FilteredActivities({
    required this.searchItems,
    required this.handleSelect,
    required this.category,
    super.key,
  });

  final List<SearchItem> searchItems;
  final Function handleSelect;
  final String category;

  @override
  Widget build(BuildContext context) {
    return HorizontalFeaturedList(
      itemCount: searchItems.length,
      itemBuilder: (context, index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () async {
                handleSelect(searchItems[index]);
              },
              child: buildActivityCard(searchItems[index], context),
            ),
          ],
        );
      },
      onPressedItem: () {},
      onPressedSeeAll: () {},
      titleText: category,
      seeAllText: '',
      titleTextStyle: Theme.of(context).textTheme.headlineMedium!,
      itemHeight: 260,
      itemWidth: 180,
      margin: 10,
      itemPadding: const EdgeInsets.only(bottom: 10, top: 10),
    );
  }

  Card buildActivityCard(SearchItem item, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Theme.of(context).colorScheme.onPrimary,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          const SizedBox(
            width: 210,
            height: 120,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
