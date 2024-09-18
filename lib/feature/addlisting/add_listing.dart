import 'package:flutter/material.dart';

class AddListingPage extends StatefulWidget {
  const AddListingPage({super.key});

  @override
  AddListingPageState createState() => AddListingPageState();
}

class AddListingPageState extends State<AddListingPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _location = 'Indore';
  String _propertyType = 'Apartment';
  String _buildingProject = '';
  String _locality = '';
  String _furnishType = '';

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final formData = {
        'name': _name,
        'location': _location,
        'propertyType': _propertyType,
        'buildingProject': _buildingProject,
        'locality': _locality,
        'furnishType': _furnishType,
      };
      print(formData);
      try {
        // final dio = Dio();
        // final response = await dio.post(
        //   'YOUR_API_ENDPOINT_HERE',
        //   data: formData,
        // );

        // if (response.statusCode == 200) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('Listing added successfully')),
        //   );
        // } else {
        //   throw Exception('Failed to add listing');
        // }
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
      appBar: AppBar(
        title: const Text('Post Property'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Your Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  onSaved: (value) => _name = value!,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _location,
                  decoration: const InputDecoration(labelText: 'Location'),
                  items: ['Indore'].map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _location = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Property Type'),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Apartment'),
                      selected: _propertyType == 'Apartment',
                      onSelected: (selected) {
                        setState(() {
                          _propertyType = 'Apartment';
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Independent Floor'),
                      selected: _propertyType == 'Independent Floor',
                      onSelected: (selected) {
                        setState(() {
                          _propertyType = 'Independent Floor';
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Independent House'),
                      selected: _propertyType == 'Independent House',
                      onSelected: (selected) {
                        setState(() {
                          _propertyType = 'Independent House';
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Villa'),
                      selected: _propertyType == 'Villa',
                      onSelected: (selected) {
                        setState(() {
                          _propertyType = 'Villa';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Building/Project/Society (Mandatory)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is mandatory';
                    }
                    return null;
                  },
                  onSaved: (value) => _buildingProject = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Locality'),
                  onSaved: (value) => _locality = value!,
                ),
                const SizedBox(height: 16),
                const Text('Furnish Type'),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Fully Furnished'),
                      selected: _furnishType == 'Fully Furnished',
                      onSelected: (selected) {
                        setState(() {
                          _furnishType = 'Fully Furnished';
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Semi Furnished'),
                      selected: _furnishType == 'Semi Furnished',
                      onSelected: (selected) {
                        setState(() {
                          _furnishType = 'Semi Furnished';
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Unfurnished'),
                      selected: _furnishType == 'Unfurnished',
                      onSelected: (selected) {
                        setState(() {
                          _furnishType = 'Unfurnished';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Next, add price details'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
