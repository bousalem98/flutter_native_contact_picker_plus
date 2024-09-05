# flutter_contact_picker_plus

An enhanced package based on flutter_native_contact_picker: This plugin allows a Flutter app to prompt users to select contacts from their address book. The contact details are returned to the app.

Utilizing the native UI for contact selection, the plugin does not require special user permissions.

Currently, it supports selecting phone numbers only. Extending it to request other contact details (like addresses) or the entire contact record is possible (PRs are encouraged).

## Features

- [x] iOS Support

  - Select single contact
  - Select multiple contacts

- [x] Android Support
  - Select single contact

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Contact Picker Example App'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MaterialButton(
                color: Colors.blue,
                child: const Text("Single"),
                onPressed: () async {
                  Contact? contact = await _contactPicker.selectContact();
                  setState(() {
                    _contacts = contact == null ? null : [contact];
                  });
                },
              ),
              MaterialButton(
                color: Colors.blue,
                child: const Text("Multiple"),
                onPressed: () async {
                  final contacts = await _contactPicker.selectContacts();
                  setState(() {
                    _contacts = contacts;
                  });
                },
              ),
              if (_contacts != null)
                ..._contacts!.map(
                  (e) => Text(e.toString()),
                )
            ],
          ),
        ),
      ),
    );
  }
}


```
