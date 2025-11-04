## [1.3.0] - Major Android Stability Patch

### 🧩 Fixes & Improvements

- 🛠 **Fixed critical crash** caused by  
  `java.lang.IllegalStateException: Couldn't read row 0, col -1 from CursorWindow`  
  This issue occurred when certain contact columns (like `PHOTO_URI` or `LOOKUP_KEY`) were missing from the query projection.  
  ✅ Resolved by adding safe column index handling across all cursor lookups.  
  ([#2](https://github.com/bousalem98/flutter_native_contact_picker_plus/issues/2) — thanks [@zjJunZhu](https://github.com/zjJunZhu))

- ☎️ **Added explicit phone type mapping** — `home`, `mobile`, `work`, and `other`  
  to make phone number fields more descriptive and consistent across Android devices.  
  Thanks [@StephenOelofsePropMe](https://github.com/StephenOelofsePropMe) for the contribution!  
  ([#1](https://github.com/bousalem98/flutter_native_contact_picker_plus/pull/1))

- 🚀 **Improved Android data safety:**

  - Added helper methods `getStringSafe()` and `getIntSafe()` to prevent invalid cursor reads.
  - Ensures compatibility across various OEM contact providers (Samsung, Xiaomi, Huawei, etc.).

- 🧠 **Code cleanup & refactoring:**
  - Streamlined `onActivityResult()` with safer cursor handling.
  - Improved error logs and fallback handling for missing contact data.

---

### ⚙️ Build Configuration Updates

- 📱 **compileSdkVersion:** 36
- 📱 **minSdkVersion:** 21
- ⚙️ **Android Gradle Plugin:** 8.13.0
- 🔒 Enforced latest AndroidX and Kotlin compatibility.

---

### 🔮 Coming Soon (v2.0.0 Roadmap)

- Smart permission layer with auto-request fallback
- Developer-selectable contact fields (e.g. name, email, avatar)
- Unified address & organization data model
- vCard export/import and live contact change listener

---

**Thanks to all contributors! 🙌**  
`flutter_native_contact_picker_plus` is now safer, faster, and more reliable on Android.

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
