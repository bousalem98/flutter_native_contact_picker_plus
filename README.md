# 📇 Flutter Native Contact Picker Plus

[![pub package](https://img.shields.io/pub/v/flutter_native_contact_picker_plus.svg)](https://pub.dev/packages/flutter_native_contact_picker_plus)
[![license](https://img.shields.io/badge/license-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

An enhanced Flutter plugin that provides **native UI to select contacts with rich, extended contact details**. Built on top of the original [`flutter_native_contact_picker`](https://pub.dev/packages/flutter_native_contact_picker), this version supports additional fields like email addresses, avatars, organization info, notes, and more — with graceful permission handling.

## ✨ Features

- ✅ No permissions required for basic info (name & phone numbers)
- 📱 Native contact picker UI for Android and iOS
- 📥 Extended contact fields (emails, avatars, addresses, etc.)
- 🔁 Multiple selection modes:
  - Single contact selection
  - Multiple contacts (iOS only)
  - Specific phone number selection
- 🔒 Graceful fallback when permission is denied

---

## 📋 Supported Platforms

| Feature                    | Android | iOS |
| -------------------------- | :-----: | :-: |
| Single contact selection   |   ✅    | ✅  |
| Multiple contact selection |   ❌    | ✅  |
| Phone number selection     |   ✅    | ✅  |
| Extended contact fields    |   ✅    | ✅  |

---

## 📦 Supported Contact Fields

| Field                 | Type                   | Requires Permission | Notes                                  |
| --------------------- | ---------------------- | ------------------- | -------------------------------------- |
| `fullName`            | `String?`              | ❌                  | Always available                       |
| `phoneNumbers`        | `List<String>?`        | ❌                  | All numbers linked to contact          |
| `selectedPhoneNumber` | `String?`              | ❌                  | Only in `selectPhoneNumber()`          |
| `emailAddresses`      | `List<EmailAddress>?`  | ✅                  | With label (e.g., work, personal)      |
| `avatar`              | `String? (base64)`     | ✅                  | Base64-encoded contact photo           |
| `postalAddresses`     | `List<PostalAddress>?` | ✅                  | Full address info with label           |
| `organizationInfo`    | `OrganizationInfo?`    | ✅                  | Company + job title                    |
| `birthday`            | `String? (ISO 8601)`   | ✅                  | Example: `1994-11-12`                  |
| `notes`               | `String?`              | ✅                  | User-entered notes                     |
| `websiteURLs`         | `List<String>?`        | ✅ (Android only)   | List of websites linked to the contact |

> ℹ️ If permissions are denied, the plugin falls back to basic fields only (`fullName`, `phoneNumbers`) **without crashing**.

---

## ⚙️ Permissions and Setup

### 🟢 Android

#### 🔐 Required Permission

Add to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_CONTACTS" />
```

#### 📦 Optional Runtime Permission Handling

Add `permission_handler` to `pubspec.yaml`:

```yaml
dependencies:
  permission_handler: ^10.2.0
```

Example usage:

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestContactPermission() async {
  var status = await Permission.contacts.request();
  if (status.isGranted) {
    // Permission granted
  } else {
    // Permission denied
  }
}
```

---

### 🍎 iOS

#### 📄 Info.plist

Add usage description to `ios/Runner/Info.plist`:

```xml
<key>NSContactsUsageDescription</key>
<string>This app requires access to contacts to allow selecting and displaying contact information.</string>
```

#### ⚙️ Podfile Update

Inside `target 'Runner' do` block of your `ios/Podfile`, add:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_CONTACTS=1'
      ]
    end
  end
end
```

#### 📦 Optional Runtime Permission Handling

Same as Android — refer to the example in the Android section.

---

### 📝 Notes

- ✅ Basic fields work even without permission.
- 🔐 Extended fields require user consent.
- ❌ If permissions are denied, the plugin doesn’t crash.
- 📱 Always test permission flows on **real devices**.

---

## 📦 Data Model

### Contact

| Property              | Type                   | Description                               |
| --------------------- | ---------------------- | ----------------------------------------- |
| `fullName`            | `String?`              | Contact name                              |
| `phoneNumbers`        | `List<String>?`        | All contact phone numbers                 |
| `selectedPhoneNumber` | `String?`              | Selected number via `selectPhoneNumber()` |
| `mobilePhoneNumber`   | `String?`              | Mobile phone number                       |
| `workPhoneNumber`     | `String?`              | Work phone number                         |
| `homePhoneNumber`     | `String?`              | Home phone number                         |
| `emailAddresses`      | `List<EmailAddress>?`  | Email addresses with labels               |
| `avatar`              | `String?`              | Base64 avatar image                       |
| `postalAddresses`     | `List<PostalAddress>?` | Address list with labels                  |
| `organizationInfo`    | `OrganizationInfo?`    | Company and job title                     |
| `birthday`            | `String?`              | ISO-8601 formatted birthday               |
| `notes`               | `String?`              | User notes                                |
| `websiteURLs`         | `List<String>?`        | Contact websites                          |

### EmailAddress

| Property | Type      | Description   |
| -------- | --------- | ------------- |
| `email`  | `String?` | Email address |
| `label`  | `String?` | e.g., "home"  |

### PostalAddress

| Property     | Type      | Description  |
| ------------ | --------- | ------------ |
| `street`     | `String?` | Street name  |
| `city`       | `String?` | City         |
| `state`      | `String?` | State        |
| `postalCode` | `String?` | Postal code  |
| `country`    | `String?` | Country name |
| `label`      | `String?` | e.g., "work" |

### OrganizationInfo

| Property   | Type      | Description  |
| ---------- | --------- | ------------ |
| `company`  | `String?` | Company name |
| `jobTitle` | `String?` | Job title    |

---

## 🧪 Example

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

## 👥 Contributors

<table>
  <tr>
    <td align="center"><a href="https://github.com/bousalem98"><img src="https://avatars.githubusercontent.com/u/61710794?v=4" width="100px;" alt=""/><br /><sub><b>Mohamed Salem</b></sub></a></td>
    <td align="center"><a href="https://github.com/jayeshpansheriya"><img src="https://avatars.githubusercontent.com/u/31765271?v=4" width="100px;" alt=""/><br /><sub><b>Jayesh Pansheriya</b></sub></a></td>
    <td align="center"><a href="https://github.com/StephenOelofsePropMe"><img src="https://avatars.githubusercontent.com/u/206001898?v=4" width="100px;" alt=""/><br /><sub><b>Stephen Oelofse</b></sub></a></td>
  </tr>
</table>
<br/>

## License

```text
BSD 3-Clause License

Copyright (c) 2020, Jayesh Pansheriya
Copyright (c) 2025, Mohamed Salem Bousalem
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
