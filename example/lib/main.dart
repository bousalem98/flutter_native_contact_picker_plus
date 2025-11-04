// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_native_contact_picker_plus/flutter_native_contact_picker_plus.dart';
import 'package:flutter_native_contact_picker_plus/model/contact_model.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const ContactPickerApp());
}

class ContactPickerApp extends StatelessWidget {
  const ContactPickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact Picker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyApp(),
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final FlutterContactPickerPlus _contactPicker = FlutterContactPickerPlus();
  List<Contact>? _contacts;
  bool _permissionGranted = false;

  Future<bool> checkPermission(Permission permission) async {
    PermissionStatus status = await permission.status;
    debugPrint(status.toString());
    switch (status) {
      case PermissionStatus.denied:
        var result = await permission.request();
        if (result == PermissionStatus.granted ||
            result == PermissionStatus.limited) {
          return true;
        } else {
          _showDeniedDialog();
          return false;
        }

      case PermissionStatus.granted:
      case PermissionStatus.limited:
        return true;

      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        _showDeniedDialog();
        return false;

      default:
        _showDeniedDialog();
        return false;
    }
  }

  void _showDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
            'Contacts permission is needed to access your contacts. Please enable it in app settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // With permission checks
  Future<void> _selectSingleContactWithPermission() async {
    final hasPermission = await checkPermission(Permission.contacts);
    setState(() {
      _permissionGranted = hasPermission;
    });
    if (!hasPermission) return;
    await _selectSingleContact();
  }

  Future<void> _selectMultipleContactsWithPermission() async {
    final hasPermission = await checkPermission(Permission.contacts);
    setState(() {
      _permissionGranted = hasPermission;
    });
    if (!hasPermission) return;
    await _selectMultipleContacts();
  }

  // Without permission checks
  Future<void> _selectSingleContact() async {
    try {
      Contact? contact = await _contactPicker.selectContact();
      setState(() {
        _contacts = contact == null ? null : [contact];
      });
    } on PlatformException catch (e) {
      _handleContactError(e);
    }
  }

  Future<void> _selectMultipleContacts() async {
    try {
      if (Platform.isIOS) {
        List<Contact>? contacts = await _contactPicker.selectContacts();
        setState(() {
          _contacts = contacts;
        });
      } else {
        List<Contact> contacts = [];
        while (true) {
          Contact? contact = await _contactPicker.selectContact();
          if (contact == null) break;
          contacts.add(contact);

          final continueSelecting = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Add another contact?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              ) ??
              false;

          if (!continueSelecting) break;
        }

        setState(() {
          _contacts = contacts.isEmpty ? null : contacts;
        });
      }
    } on PlatformException catch (e) {
      _handleContactError(e);
    }
  }

  Future<void> _selectPhoneNumber() async {
    try {
      Contact? contact = await _contactPicker.selectPhoneNumber();
      setState(() {
        _contacts = contact == null ? null : [contact];
      });
    } on PlatformException catch (e) {
      _handleContactError(e);
    }
  }

  void _handleContactError(PlatformException e) {
    if (e.code == 'PERMISSION_DENIED') {
      _showDeniedDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Picker with Permissions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _contacts = null),
            tooltip: 'Clear Contacts',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Contact Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _permissionGranted
                      ? 'Permission: Granted'
                      : 'Permission: Denied',
                  style: TextStyle(
                    color: _permissionGranted ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildActionButton(
                      icon: Icons.person_add,
                      label: 'Single (with perm)',
                      onPressed: _selectSingleContactWithPermission,
                      color: Colors.green,
                    ),
                    _buildActionButton(
                      icon: Icons.group_add,
                      label: 'Multi (with perm)',
                      onPressed: _selectMultipleContactsWithPermission,
                      color: Colors.green,
                    ),
                    _buildActionButton(
                      icon: Icons.person_outline,
                      label: 'Single (no perm)',
                      onPressed: _selectSingleContact,
                      color: Colors.blue,
                    ),
                    _buildActionButton(
                      icon: Icons.group_outlined,
                      label: 'Multi (no perm)',
                      onPressed: _selectMultipleContacts,
                      color: Colors.blue,
                    ),
                    _buildActionButton(
                      icon: Icons.phone,
                      label: 'Phone Number',
                      onPressed: _selectPhoneNumber,
                      color: Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _contacts == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.contacts, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No contacts selected',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _contacts!.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts![index];
                      return _buildContactCard(contact);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildContactCard(Contact contact) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar and Name Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (contact.avatar != null)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: MemoryImage(base64Decode(contact.avatar!)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                if (contact.avatar == null)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.indigo,
                    ),
                    child:
                        const Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.fullName ?? 'Unknown Name',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (contact.organizationInfo?.jobTitle != null ||
                          contact.organizationInfo?.company != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            [
                              contact.organizationInfo?.jobTitle,
                              contact.organizationInfo?.company
                            ].where((e) => e != null).join(' at '),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Contact Information Sections
            if (contact.phoneNumbers != null &&
                contact.phoneNumbers!.isNotEmpty)
              _buildSection(
                Icons.phone,
                'Phone Numbers',
                contact.phoneNumbers!
                    .map((number) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.phone, size: 24),
                          title: Text(number),
                          onTap: () => _launchPhoneCall(number),
                        ))
                    .toList(),
              ),

            if (contact.selectedPhoneNumber != null)
              _buildSection(
                Icons.phone_android,
                'Selected Phone',
                [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading:
                        const Icon(Icons.star, color: Colors.amber, size: 24),
                    title: Text(contact.selectedPhoneNumber!),
                    onTap: () => _launchPhoneCall(contact.selectedPhoneNumber!),
                  )
                ],
              ),

            if (contact.emailAddresses != null &&
                contact.emailAddresses!.isNotEmpty)
              _buildSection(
                Icons.email,
                'Email Addresses',
                contact.emailAddresses!
                    .map((email) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.email, size: 24),
                          title: Text(email.email ?? ''),
                          subtitle:
                              email.label != null ? Text(email.label!) : null,
                          onTap: () => _launchEmail(email.email),
                        ))
                    .toList(),
              ),

            if (contact.postalAddresses != null &&
                contact.postalAddresses!.isNotEmpty)
              _buildSection(
                Icons.location_on,
                'Addresses',
                contact.postalAddresses!
                    .map((address) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.location_on, size: 24),
                          title: Text(
                            [
                              address.street,
                              address.city,
                              address.state,
                              address.postalCode,
                              address.country
                            ].where((e) => e != null).join(', '),
                          ),
                          subtitle: address.label != null
                              ? Text(address.label!)
                              : null,
                          onTap: () => _launchMaps(address),
                        ))
                    .toList(),
              ),

            if (contact.organizationInfo != null &&
                (contact.organizationInfo?.company != null ||
                    contact.organizationInfo?.jobTitle != null))
              _buildSection(
                Icons.business,
                'Organization',
                [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.business, size: 24),
                    title: Text(contact.organizationInfo?.company ?? ''),
                    subtitle: contact.organizationInfo?.jobTitle != null
                        ? Text(contact.organizationInfo!.jobTitle!)
                        : null,
                  )
                ],
              ),

            if (contact.birthday != null)
              _buildSection(
                Icons.cake,
                'Birthday',
                [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.cake, size: 24),
                    title: Text(contact.birthday!),
                  )
                ],
              ),

            if (contact.notes != null)
              _buildSection(
                Icons.notes,
                'Notes',
                [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.notes, size: 24),
                    title: Text(contact.notes!),
                  )
                ],
              ),

            if (contact.websiteURLs != null && contact.websiteURLs!.isNotEmpty)
              _buildSection(
                Icons.link,
                'Websites',
                contact.websiteURLs!
                    .map((url) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.link, size: 24),
                          title: Text(url),
                          onTap: () => _launchUrl(url),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

// Helper methods for actions
  Future<void> _launchPhoneCall(String? phoneNumber) async {
    if (phoneNumber == null) return;
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String? email) async {
    if (email == null) return;
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchUrl(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchMaps(PostalAddress address) async {
    final query = [
      address.street,
      address.city,
      address.state,
      address.postalCode,
      address.country
    ].where((e) => e != null).join(', ');
    final uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildSection(IconData icon, String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: Colors.indigo),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Column(children: children),
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }
}
