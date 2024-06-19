import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class SearchItem extends HiveObject {
  SearchItem({
    required this.id,
    required this.title,
    required this.searchTerm,
  });
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String searchTerm;
}
