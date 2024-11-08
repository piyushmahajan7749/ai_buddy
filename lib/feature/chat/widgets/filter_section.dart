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
  Map<String, dynamic> selectedFilters = {};
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();

  @override
  void dispose() {
    _priceController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  void _searchWithFilters() {
    // Close the filter section
    setState(() {
      _showFilters = false;
    });
    String filterMessage = 'Search for properties with:';
    selectedFilters.forEach((key, value) {
      filterMessage += '\n- $key: $value';
    });

    // Send the filter message as a chat message
    ref.read(messageListProvider.notifier).addFilterMessage(filterMessage);

    // Clear the filters after sending
    setState(() {
      selectedFilters.clear();
      _priceController.clear();
      _areaController.clear();
    });
  }

  Widget _buildNumberInput(
    String label,
    TextEditingController controller,
    String key,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixText: key == 'price' ? '₹' : 'sq ft',
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          if (value.isNotEmpty) {
            selectedFilters[key] = int.parse(value);
          } else {
            selectedFilters.remove(key);
          }
        },
      ),
    );
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
                  onDeleted: _toggleFilters,
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
                      _buildNumberInput('Price', _priceController, 'price'),
                      _buildNumberInput('Area', _areaController, 'area'),
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
                                  ? Theme.of(context).colorScheme.surface
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
