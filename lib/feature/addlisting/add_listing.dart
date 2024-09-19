import 'dart:io';
import 'package:ai_buddy/core/util/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AddListingPage extends StatefulWidget {
  const AddListingPage({super.key});

  @override
  AddListingPageState createState() => AddListingPageState();
}

class AddListingPageState extends State<AddListingPage> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> formData = {};

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final dio = Dio(BaseOptions(baseUrl: endpointUrl));
        final response = await dio.post<dynamic>(
          '/add_listing',
          data: formData,
          options: Options(
              headers: {HttpHeaders.contentTypeHeader: 'application/json'}),
        );

        if (response.statusCode == 200 && response.data != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing added successfully')),
          );
        } else {
          throw Exception('Failed to add listing');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Property')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextInput('Your Full Name', 'name'),
                _buildTextInput('Your Contact Number', 'contact_number'),
                _buildFilterGroup(
                    'Requirement', ['Sell', 'Rent', 'Lease'], 'requirement'),
                _buildFilterGroup(
                    'Property Type',
                    ['Flat', 'Plot', 'Office', 'Shop', 'Hostel', 'House'],
                    'property_type'),
                _buildLocationInput(),
                _buildFilterGroup(
                    'Bedrooms',
                    ['1RK', '1BHK', '2BHK', '3BHK', '4BHK', '5+BHK'],
                    'bedrooms'),
                _buildFilterGroup(
                    'Property Subtype',
                    ['Agricultural', 'Commercial', 'Residential'],
                    'property_subtype'),
                _buildNumberInput('Price (₹)', 'price_range', isPrice: true),
                _buildNumberInput('Area (sq ft)', 'area'),
                _buildTextInput('Additional Features', 'additional_features',
                    maxLines: 3),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(
                      'Submit Listing',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.background,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterGroup(
      String title, List<String> options, String filterKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: options
              .map((option) => FilterChip(
                    label: Text(option),
                    selected: formData[filterKey] == option,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          formData[filterKey] = option;
                        } else {
                          formData.remove(filterKey);
                        }
                      });
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildNumberInput(String label, String key, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
        onSaved: (value) {
          if (isPrice) {
            formData[key] = value; // Store price as String
          } else {
            formData[key] = int.parse(value!);
          }
        },
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
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(),
            ),
            onSaved: (value) => formData['location'] = value,
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput(String label, String key, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        onSaved: (value) => formData[key] = value,
      ),
    );
  }
}
