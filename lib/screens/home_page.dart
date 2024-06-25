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
        floatingActionButton: FloatingActionButton(
          backgroundColor: colorOffBlue,
          foregroundColor: colorWhite,
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
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // Sliver AppBar
                  SliverAppBar(
                    title: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: colorWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                    ),
                    backgroundColor: colorOffBlue,
                    expandedHeight: 120.0,
                    floating: true,
                    pinned: true,
                    snap: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        padding: const EdgeInsets.only(top: 70.0),
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.05),
                          child: Container(
                            height: 50,
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: colorDark.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(color: colorWhite, fontSize: 18),
                                border: InputBorder.none,
                                alignLabelWithHint: true,
                                prefixIcon: const Icon(
                                  Icons.search,
                                  size: 14,
                                  color: colorWhite,
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: colorWhite, size: 14),
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterContacts();
                                  },
                                ),
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: colorWhite, fontSize: 18),
                              textAlignVertical: TextAlignVertical.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(
                        top: 16.0, left: 16.0, right: 16.0),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          Text(
                            "Contacts ${_filteredContacts.length}",
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      color: colorBlack,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        Contact contact = _filteredContacts[index];
                        return ListTile(
                          onTap: () async {
                            String? phoneNumber = contact.phones!.first.value;
                            if (phoneNumber != null) {
                              await _makePhoneCall(phoneNumber);
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
                      childCount: _filteredContacts.length,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
