// ignore_for_file: only_throw_errors

import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/colors.dart';
import 'add_contact.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key, required this.title});
  final String title;

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchContacts();
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchContacts() async {
    // Request permission to access contacts
    if (await Permission.contacts.request().isGranted) {
      // Get all contacts
      Iterable<Contact> contacts = await ContactsService.getContacts();
      setState(() {
        _contacts = contacts.toList();
        _filteredContacts = _contacts;
      });
    }
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _contacts.where((contact) {
        return contact.displayName != null &&
            contact.displayName!.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    String url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorPrimary,
          title: Text(
            widget.title,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: colorWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
          ),
          centerTitle: false,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: colorPrimary,
          foregroundColor: colorWhite,
          // elevation: 0,
          shape: const CircleBorder(),
          onPressed: () {
            Get.to(
              () => const AddContactPage(),
              transition: Transition.circularReveal,
              popGesture: true,
            );
          },
          child: const Icon(
            Icons.add,
            color: colorWhite,
            size: 20,
          ),
        ),
        body: _contacts.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorDark.withOpacity(0.5)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: colorDark, fontSize: 20),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: colorDark, fontSize: 14),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.search,
                            size: 18,
                            color: colorDark,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear, color: colorDark, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _filterContacts();
                            },
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "My Contacts",
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: colorBlack,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                        ),

                        // Total Length of contacts
                        Text(
                          _filteredContacts.length.toString(),
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: colorBlack,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                        ),
                      ],
                    ),
                  ),

                  // Contacts List
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filteredContacts.length,
                      itemBuilder: (context, index) {
                        Contact contact = _filteredContacts[index];
                        return ListTile(
                          onTap: () async {
                            String? phoneNumber = contact.phones!.first.value;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Phone number: $phoneNumber"),
                                backgroundColor: colorBlue,
                              ),
                            );
                            if (phoneNumber != null) {
                              await _makePhoneCall(phoneNumber);
                              print("Phone number: $phoneNumber");
                            }
                          },
                          leading: (contact.avatar != null &&
                                  contact.avatar!.isNotEmpty)
                              ? CircleAvatar(
                                  backgroundColor: colorDark,
                                  backgroundImage: MemoryImage(contact.avatar!),
                                )
                              : CircleAvatar(
                                  backgroundColor: colorDark,
                                  child: Text(
                                    contact.initials(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: colorWhite,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                  ),
                                ),
                          title: Text(
                            contact.displayName ?? 'No Name',
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: colorBlack,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                    ),
                          ),
                          subtitle: Text(
                            contact.phones != null && contact.phones!.isNotEmpty
                                ? contact.phones!.first.value ?? 'No Number'
                                : 'No Number',
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: colorBlack,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                    ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
