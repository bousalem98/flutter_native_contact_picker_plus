# Flutter Native Contact Picker Plus

[![pub package](https://img.shields.io/pub/v/flutter_native_contact_picker_plus.svg)](https://pub.dev/packages/flutter_native_contact_picker_plus)
[![license](https://img.shields.io/badge/license-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

An enhanced Flutter plugin that provides native UI to select contacts with comprehensive contact details, built on top of the original `flutter_native_contact_picker` with additional features and fields.

## ✨ Features

- **No permissions required** for basic contact information (name and phone numbers)
- **Native UI** for both Android and iOS
- **Comprehensive contact details** including emails, addresses, organization info, and more
- **Multiple selection modes**:
  - Single contact selection
  - Multiple contact selection (iOS only)
  - Specific phone number selection
- **Graceful permission handling** - works even when permissions are denied

## 📋 Supported Platforms

| Feature                    | Android | iOS |
| -------------------------- | :-----: | :-: |
| Single contact selection   |   ✅    | ✅  |
| Multiple contact selection |   ❌    | ✅  |
| Phone number selection     |   ✅    | ✅  |
| Extended contact fields    |   ✅    | ✅  |

## 📋 Supported Contact Fields

| Field                 | Type                   | Permission Required | Notes                                        |
| --------------------- | ---------------------- | ------------------- | -------------------------------------------- |
| `fullName`            | `String?`              | ❌                  | Always available                             |
| `phoneNumbers`        | `List<String>?`        | ❌                  | All phone numbers attached to the contact    |
| `selectedPhoneNumber` | `String?`              | ❌                  | Used only in `selectPhoneNumber()`           |
| `emailAddresses`      | `List<EmailAddress>?`  | ✅                  | Email + label; permission needed to retrieve |
| `avatar`              | `String? (base64)`     | ✅                  | Base64-encoded avatar image                  |
| `postalAddresses`     | `List<PostalAddress>?` | ✅                  | Full address info with label                 |
| `organizationInfo`    | `OrganizationInfo?`    | ✅                  | Includes company and job title               |
| `birthday`            | `String?` (ISO 8601)   | ✅                  | Example: `1994-11-12`                        |
| `notes`               | `String?`              | ✅                  | User-provided notes                          |
| `websiteURLs`         | `List<String>?`        | ✅ (Android only)   | List of associated websites                  |

> ℹ️ If access is denied by the user, only basic fields (`fullName`, `phoneNumbers`) are returned. The plugin will not crash or throw.

---

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_native_contact_picker_plus: ^1.0.2
```

---

## ⚙️ Permissions

| Platform | Permission                         | Required For                                                                                         |
| -------- | ---------------------------------- | ---------------------------------------------------------------------------------------------------- |
| Android  | `android.permission.READ_CONTACTS` | Required for accessing email, avatar, postal addresses, organization info, birthday, notes, websites |
| iOS      | `NSContactsUsageDescription`       | Required for accessing email, avatar, postal addresses, organization info, birthday, notes, websites |

> **Note:**
>
> - Basic fields like `fullName`, `phoneNumbers`, and `selectedPhoneNumber` can be accessed **without any permission** when using the native contact picker UI.
> - Access to other detailed fields requires user permission and may be denied gracefully.

---

## 📦 Data Model

### Contact

Represents a contact selected by the user.

| Property              | Type                   | Description                                      |
| --------------------- | ---------------------- | ------------------------------------------------ |
| `fullName`            | `String?`              | Contact's full name                              |
| `phoneNumbers`        | `List<String>?`        | All phone numbers attached to the contact        |
| `selectedPhoneNumber` | `String?`              | The phone number selected specifically (if any)  |
| `emailAddresses`      | `List<EmailAddress>?`  | List of email addresses with labels              |
| `avatar`              | `String?`              | Base64-encoded avatar image (nullable)           |
| `postalAddresses`     | `List<PostalAddress>?` | List of postal addresses with labels             |
| `organizationInfo`    | `OrganizationInfo?`    | Company and job title info                       |
| `birthday`            | `String?`              | Birthday in ISO 8601 format (e.g., `1994-11-12`) |
| `notes`               | `String?`              | User notes                                       |
| `websiteURLs`         | `List<String>?`        | List of website URLs                             |

### EmailAddress

Represents an email address with a label.

| Property | Type      | Description          |
| -------- | --------- | -------------------- |
| `email`  | `String?` | Email address        |
| `label`  | `String?` | Label (e.g., "home") |

### PostalAddress

Represents a postal address.

| Property     | Type      | Description          |
| ------------ | --------- | -------------------- |
| `street`     | `String?` | Street address       |
| `city`       | `String?` | City                 |
| `state`      | `String?` | State                |
| `postalCode` | `String?` | Postal code          |
| `country`    | `String?` | Country              |
| `label`      | `String?` | Label (e.g., "work") |

### OrganizationInfo

Represents organization information.

| Property   | Type      | Description  |
| ---------- | --------- | ------------ |
| `company`  | `String?` | Company name |
| `jobTitle` | `String?` | Job title    |

---

### Example

```dart
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
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Contact Picker Plus Example')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      Contact? contact = await _contactPicker.selectContact();
                      setState(() => _contacts = contact == null ? null : [contact]);
                    },
                    child: const Text('Select Single Contact'),
                  ),
                  ElevatedButton(
                    onPressed: Platform.isIOS
                        ? () async {
                            List<Contact>? contacts = await _contactPicker.selectContacts();
                            setState(() => _contacts = contacts);
                          }
                        : null,
                    child: const Text('Select Multiple Contacts'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Contact? contact = await _contactPicker.selectPhoneNumber();
                      setState(() => _contacts = contact == null ? null : [contact]);
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
                                        errorBuilder: (_, __, ___) => const Icon(Icons.error, size: 100),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Text(contact.fullName ?? 'Unknown Name',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                if (contact.phoneNumbers != null && contact.phoneNumbers!.isNotEmpty)
                                  _buildSection('Phone Numbers', contact.phoneNumbers!.map((e) => Text(e)).toList()),
                                if (contact.selectedPhoneNumber != null)
                                  _buildSection('Selected Phone Number', [Text(contact.selectedPhoneNumber!)]),
                                if (contact.emailAddresses != null && contact.emailAddresses!.isNotEmpty)
                                  _buildSection('Email Addresses', contact.emailAddresses!.map((e) => Text(e.toString())).toList()),
                                if (contact.postalAddresses != null && contact.postalAddresses!.isNotEmpty)
                                  _buildSection('Postal Addresses', contact.postalAddresses!.map((e) => Text(e.toString())).toList()),
                                if (contact.organizationInfo != null)
                                  _buildSection('Organization', [Text(contact.organizationInfo!.toString())]),
                                if (contact.birthday != null)
                                  _buildSection('Birthday', [Text(contact.birthday!)]),
                                if (contact.notes != null)
                                  _buildSection('Notes', [Text(contact.notes!)]),
                                if (contact.websiteURLs != null && contact.websiteURLs!.isNotEmpty)
                                  _buildSection('Website URLs', contact.websiteURLs!.map((e) => Text(e)).toList()),
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
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        ...children,
        const SizedBox(height: 8),
      ],
    );
  }
}

```

Also, for whole example, check out the **example** app in the [example](https://github.com/bousalem98/flutter_native_contact_picker_plus/tree/main/example) directory or the 'Example' tab on pub.dartlang.org for a more complete example.

## Main Contributors

<table>
  <tr>
    <td align="center"><a href="https://github.com/bousalem98"><img src="https://avatars.githubusercontent.com/u/61710794?v=4" width="100px;" alt=""/><br /><sub><b>Mohamed Salem</b></sub></a></td>
    <td align="center"><a href="https://github.com/jayeshpansheriya"><img src="https://avatars.githubusercontent.com/u/31765271?v=4" width="100px;" alt=""/><br /><sub><b>Jayesh Pansheriya</b></sub></a></td>
  </tr>
</table>
<br/>

## License

```text
BSD 3-Clause License

Copyright (c) 2020, Jayesh Pansheriya
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```
