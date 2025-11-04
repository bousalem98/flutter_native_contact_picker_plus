## [1.2.0] - Patch

- Fix Issue Caused by java.lang.IllegalStateException Couldn't read row 0, col -1 from CursorWindow. Make sure the Cursor is initialized correctly before accessing data from it. (https://github.com/bousalem98/flutter_native_contact_picker_plus/issues/2)
- Update Android Gradle plugin to 8.13.0
- Android build: compileSdkVersion 36, minSdk 21
- Explicit mobile, work, home phone number properties to contact, Thanks [@StephenOelofsePropMe](https://github.com/bousalem98/flutter_native_contact_picker_plus/pull/1)

## [1.1.1] - Swift Package Manager

- fix ios issues.
- support the Swift package manager

---

## [1.0.0] - Major Update

### 🚀 New Features

- **Added** `selectPhoneNumber` method to select a specific phone number from a contact.

### 📱 Extended Contact Fields

> Most fields require permission and will be returned only if access is granted. The plugin works gracefully even if the permission is not provided.

- `selectedPhoneNumber`: Used with the `selectPhoneNumber` method.
- `emailAddresses`: List of emails with labels.  
  _Requires `READ_CONTACTS` on Android / user authorization on iOS._
- `avatar`: **Base64-encoded** image of the contact.  
  _Requires permission on both platforms._
- `postalAddresses`: Includes street, city, state, postal code, country, and label.  
  _Requires permission._
- `organizationInfo`: Contains company and job title.  
  _Requires permission._
- `birthday`: ISO 8601 formatted date string.  
  _Requires permission._
- `notes`: Free-form notes.  
  _Requires permission._
- `websiteURLs`: List of contact-related website URLs.  
  _Requires permission (Android only)._

### 💡 Enhancements

- Improved example app to showcase all available methods and fields.
- Graceful fallback when permissions are denied (fields return `null` or empty).
- Updated Android and iOS implementations for better compatibility.

---

## [0.0.2] - Patch

- Fixed iOS issues.

---

## [0.0.1] - Initial Release

- First release of the package.
