import 'dart:io';
import 'package:ai_buddy/core/util/btnutils.dart';
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
              automaticallyImplyLeading:
                  false, // This line removes the back button
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildAIAssistantTab(),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              child: buildOutlinedButton(
                'Submit Listing',
                _submitAIDescription,
                context,
              ),
            ),
          ],
        ),
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
