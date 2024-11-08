import 'dart:io';
import 'package:ai_buddy/core/util/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddListingPage extends StatefulWidget {
  const AddListingPage({super.key});

  @override
  AddListingPageState createState() => AddListingPageState();
}

class AddListingPageState extends State<AddListingPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> formData = {};
  late TabController _tabController;
  final TextEditingController _aiDescriptionController =
      TextEditingController();
  final TextEditingController _aiNameController = TextEditingController();
  final TextEditingController _aiContactController = TextEditingController();
  bool _isLoading = false;
  bool isOwnerListing = true; // Add this line

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _aiDescriptionController.dispose();
    _aiNameController.dispose();
    _aiContactController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Add this line to include isOwnerListing in the form data
      formData['isOwnerListing'] = isOwnerListing;

      setState(() {
        _isLoading = true;
      });

      try {
        final dio = Dio(BaseOptions(baseUrl: endpointUrl));
        final response = await dio.post<dynamic>(
          '/add_listing',
          data: formData,
          options: Options(
            headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          ),
        );

        if (response.statusCode == 201 && response.data != null) {
          _formKey.currentState!.reset();
          await Fluttertoast.showToast(
            msg: 'Listing added successfully!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            // ignore: use_build_context_synchronously
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            // ignore: use_build_context_synchronously
            textColor: Theme.of(context).colorScheme.surface,
            fontSize: 16,
          );
        } else {
          throw Exception('Failed to add listing');
        }
      } catch (e) {
        await Fluttertoast.showToast(
          msg: 'Error: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitAIDescription() async {
    final description = _aiDescriptionController.text;
    final name = _aiNameController.text;
    final contact = _aiContactController.text;
    final aiFormData = {
      'description': description,
      'name': name,
      'contact': contact,
      'isOwnerListing': isOwnerListing, // Add this line
    };

    if (description.isNotEmpty && name.isNotEmpty && contact.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        final dio = Dio(BaseOptions(baseUrl: endpointUrl));
        final response = await dio.post<dynamic>(
          '/add_listing_from_message',
          data: aiFormData,
          options: Options(
            headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          ),
        );

        if (response.statusCode == 201 && response.data != null) {
          _aiDescriptionController.clear();
          _aiNameController.clear();
          _aiContactController.clear();
          await Fluttertoast.showToast(
            msg: 'Listing added successfully!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            // ignore: use_build_context_synchronously
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            // ignore: use_build_context_synchronously
            textColor: Theme.of(context).colorScheme.surface,
            fontSize: 16,
          );
        } else {
          throw Exception('Failed to add listing');
        }
      } catch (e) {
        await Fluttertoast.showToast(
          msg: 'Error: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      await Fluttertoast.showToast(
        msg: 'Please fill in all fields',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              title: const Text('Add Listing'),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'AI Assistant'),
                  Tab(text: 'Manual Entry'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildAIAssistantTab(),
                _buildManualEntryTab(),
              ],
            ),
          ),
        ),
        if (_isLoading)
          ColoredBox(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildAIAssistantTab() {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              AppBar().preferredSize.height -
              MediaQuery.of(context).padding.top,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Describe your property',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _aiDescriptionController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'E.g., "A spacious 3BHK apartment in '
                          'Vijay Nagar, fully furnished, and close to '
                          'public transport."',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _aiNameController,
                    decoration: const InputDecoration(
                      labelText: 'Your Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _aiContactController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 30),
                  _buildOwnerListingSwitch(), // Add this line
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitAIDescription,
                  child: Text(
                    'Submit Listing',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualEntryTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterGroup(
                'Requirement',
                ['Sell', 'Rent', 'Lease'],
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
              _buildNumberInput('Price (₹)', 'price', isPrice: true),
              _buildNumberInput('Area (sq ft)', 'area'),
              _buildTextInput('Name', 'name'),
              _buildTextInput('Contact Number', 'contact_number'),
              _buildTextInput(
                'Additional Features',
                'additional_features',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildOwnerListingSwitch(), // Add this line
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(
                    'Submit Listing',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
          child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: options
              .map(
                (option) => FilterChip(
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
                ),
              )
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
            formData[key] = double.parse(value!);
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

  // Add this new method
  Widget _buildOwnerListingSwitch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Are you the owner of this listing?',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Row(
          children: [
            Text(
              isOwnerListing ? 'Yes' : 'No',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(width: 8),
            Switch(
              value: isOwnerListing,
              onChanged: (value) {
                setState(() {
                  isOwnerListing = value;
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}
