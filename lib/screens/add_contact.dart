// ignore_for_file: library_private_types_in_public_api

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

import '../utils/colors.dart';

class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key});

  @override
  _AddContactPageState createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorOffBlue,
          iconTheme: const IconThemeData(color: colorWhite),
          title: Text(
            "Add Contact",
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: colorWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05),
                child: Container(
                  height: 50,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorOffBlue, width: 1.2),
                  ),
                  child: TextField(
                    controller: _nameController,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: colorOffBlue, fontSize: 20),
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: colorOffBlue, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.05),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05),
                child: Container(
                  height: 50,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorOffBlue, width: 1.2),
                  ),
                  child: TextField(
                    controller: _phoneController,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: colorOffBlue, fontSize: 20),
                    decoration: InputDecoration(
                      hintText: 'Phone',
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: colorOffBlue, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.05),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: 50.0,
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05),
                child: ElevatedButton(
                  onPressed: () async {
                    final String name = _nameController.text.trim();
                    final String phone = _phoneController.text.trim();

                    if (name.isNotEmpty && phone.isNotEmpty) {
                      // Format the phone number to remove non-numeric characters
                      String formattedPhone =
                          phone.replaceAll(RegExp(r'[^\d]'), '');

                      // Create a new contact
                      Contact newContact = Contact();
                      newContact.givenName = name;
                      newContact.phones = [
                        Item(label: 'mobile', value: formattedPhone)
                      ];

                      // Add the contact to the database
                      try {
                        await ContactsService.addContact(newContact);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Contact added successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to add contact: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill in all fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorOffBlue,
                    foregroundColor: colorWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 0,
                    textStyle: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
