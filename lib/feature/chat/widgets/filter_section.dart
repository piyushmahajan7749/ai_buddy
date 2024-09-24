import 'package:ai_buddy/feature/chat/provider/message_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterSection extends ConsumerStatefulWidget {
  const FilterSection({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FilterSectionState createState() => _FilterSectionState();
}

class _FilterSectionState extends ConsumerState<FilterSection> {
  bool _showFilters = false;
  RangeValues _priceRange = const RangeValues(0, 10000000);
  RangeValues _areaRange = const RangeValues(0, 10000);
  Map<String, dynamic> selectedFilters = {};

  void removeFilter(String key) {
    setState(() {
      selectedFilters.remove(key);
      if (key == 'price_range') {
        _priceRange = const RangeValues(0, 10000000);
      } else if (key == 'area') {
        _areaRange = const RangeValues(0, 10000);
      }
    });
    ref.read(messageListProvider.notifier).setFilter(key, null);
  }

  void _searchWithFilters() {
    // Close the filter section
    setState(() {
      _showFilters = false;
    });

    // Prepare the filter message
    String filterMessage = 'Search for properties with:';
    selectedFilters.forEach((key, value) {
      filterMessage += '\n- $key: $value';
    });

    // Send the filter message as a chat message
    ref.read(messageListProvider.notifier).addMessage(filterMessage);

    // Clear the filters after sending
    setState(() {
      selectedFilters.clear();
      _priceRange = const RangeValues(0, 10000000);
      _areaRange = const RangeValues(0, 10000);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              'Filters',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            trailing: IconButton(
              icon: Icon(_showFilters ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(() => _showFilters = !_showFilters),
            ),
          ),
          if (!_showFilters && selectedFilters.isNotEmpty)
            Wrap(
              spacing: 8,
              children: selectedFilters.entries.map((entry) {
                return Chip(
                  label: Text('${entry.key}: ${entry.value}'),
                  onDeleted: () => removeFilter(entry.key),
                );
              }).toList(),
            ),
          if (_showFilters)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterGroup(
                        'Requirement',
                        ['Buy', 'Sell', 'Rent', 'Lease'],
                        'requirement',
                      ),
                      _buildFilterGroup(
                        'Property Type',
                        ['Flat', 'Plot', 'Office', 'Shop', 'Hostel', 'House'],
                        'property_type',
                      ),
                      _buildLocationInput(),
                      _buildFilterGroup(
                        'Bedrooms',
                        ['1RK', '1BHK', '2BHK', '3BHK', '4BHK', '5+BHK'],
                        'bedrooms',
                      ),
                      _buildFilterGroup(
                        'Property Subtype',
                        ['Agricultural', 'Commercial', 'Residential'],
                        'property_subtype',
                      ),
                      _buildRangeSlider(
                          'Price Range (₹)', _priceRange, 0, 10000000,
                          (values) {
                        setState(() {
                          _priceRange = values;
                          selectedFilters['price_range'] =
                              '${values.start.round()}-${values.end.round()}';
                        });
                        ref.read(messageListProvider.notifier).setFilter(
                              'price_range',
                              '${values.start.round()}-${values.end.round()}',
                            );
                      }),
                      _buildRangeSlider('Area (sq ft)', _areaRange, 0, 10000,
                          (values) {
                        setState(() {
                          _areaRange = values;
                          selectedFilters['area'] =
                              '${values.start.round()}-${values.end.round()}';
                        });
                        ref.read(messageListProvider.notifier).setFilter(
                              'area',
                              '${values.start.round()}-${values.end.round()}',
                            );
                      }),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: selectedFilters.isNotEmpty
                              ? _searchWithFilters
                              : null,
                          child: Text(
                            'Search with Filters',
                            style: TextStyle(
                              color: selectedFilters.isNotEmpty
                                  ? Theme.of(context).colorScheme.background
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterGroup(
    String title,
    List<String> options,
    String filterKey,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: options
              .map(
                (option) => FilterChip(
                  label: Text(option),
                  selected: selectedFilters[filterKey] == option,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedFilters[filterKey] = option;
                      } else {
                        selectedFilters.remove(filterKey);
                      }
                    });
                    ref
                        .read(messageListProvider.notifier)
                        .setFilter(filterKey, selected ? option : null);
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildRangeSlider(
    String title,
    RangeValues values,
    double min,
    double max,
    void Function(RangeValues) onChanged,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
          ),
          RangeSlider(
            values: values,
            min: min,
            max: max,
            divisions: 100,
            labels: RangeLabels(
              values.start.round().toString(),
              values.end.round().toString(),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child:
                Text('Location', style: Theme.of(context).textTheme.bodyLarge),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isNotEmpty) {
                    selectedFilters['location'] = value;
                  } else {
                    selectedFilters.remove('location');
                  }
                });
                ref
                    .read(messageListProvider.notifier)
                    .setFilter('location', value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
