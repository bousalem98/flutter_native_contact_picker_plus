import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_contact_picker_plus/flutter_native_contact_picker_plus.dart';
import 'package:flutter_native_contact_picker_plus/model/contact_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final FlutterContactPickerPlus _contactPicker = FlutterContactPickerPlus();
  List<Contact>? _contacts;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Contact Picker Plus Example'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      try {
                        Contact? contact = await _contactPicker.selectContact();
                        setState(() {
                          _contacts = contact == null ? null : [contact];
                        });
                      } catch (e) {
                        if (e is PlatformException &&
                            e.code == 'PERMISSION_DENIED') {
                          // Show message to user about needing contacts permission
                        } else {
                          // Handle other errors
                        }
                      }
                    },
                    child: const Text('Select Single Contact'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: Platform.isIOS
                        ? () async {
                            List<Contact>? contacts =
                                await _contactPicker.selectContacts();
                            setState(() {
                              _contacts = contacts;
                            });
                          }
                        : null,
                    child: const Text('Select Multiple Contacts'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      Contact? contact =
                          await _contactPicker.selectPhoneNumber();
                      setState(() {
                        _contacts = contact == null ? null : [contact];
                      });
                    },
                    child: const Text('Select Phone Number'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _contacts == null
                  ? const Center(child: Text('No contacts selected'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _contacts!.length,
                      itemBuilder: (context, index) {
                        final contact = _contacts![index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (contact.avatar != null)
                                  Center(
                                    child: ClipOval(
                                      child: Image.memory(
                                        base64Decode(contact.avatar!),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            const Icon(Icons.error, size: 100),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  contact.fullName ?? 'Unknown Name',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                if (contact.phoneNumbers != null &&
                                    contact.phoneNumbers!.isNotEmpty)
                                  _buildSection(
                                      'Phone Numbers',
                                      contact.phoneNumbers!
                                          .map((e) => Text(e))
                                          .toList()),
                                if (contact.selectedPhoneNumber != null)
                                  _buildSection('Selected Phone Number',
                                      [Text(contact.selectedPhoneNumber!)]),
                                if (contact.emailAddresses != null &&
                                    contact.emailAddresses!.isNotEmpty)
                                  _buildSection(
                                      'Email Addresses',
                                      contact.emailAddresses!
                                          .map((e) => Text(e.toString()))
                                          .toList()),
                                if (contact.postalAddresses != null &&
                                    contact.postalAddresses!.isNotEmpty)
                                  _buildSection(
                                      'Postal Addresses',
                                      contact.postalAddresses!
                                          .map((e) => Text(e.toString()))
                                          .toList()),
                                if (contact.organizationInfo != null)
                                  _buildSection('Organization', [
                                    Text(contact.organizationInfo!.toString())
                                  ]),
                                if (contact.birthday != null)
                                  _buildSection(
                                      'Birthday', [Text(contact.birthday!)]),
                                if (contact.notes != null)
                                  _buildSection(
                                      'Notes', [Text(contact.notes!)]),
                                if (contact.websiteURLs != null &&
                                    contact.websiteURLs!.isNotEmpty)
                                  _buildSection(
                                      'Website URLs',
                                      contact.websiteURLs!
                                          .map((e) => Text(e))
                                          .toList()),
                              ],
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

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        ...children,
        const SizedBox(height: 8),
      ],
    );
  }
}
