/// Represents a contact selected by the user from the native contact picker.
class Contact {
  /// Creates a [Contact] instance with all possible contact details.
  Contact({
    this.fullName,
    this.phoneNumbers,
    this.workPhoneNumber,
    this.homePhoneNumber,
    this.mobilePhoneNumber,
    this.selectedPhoneNumber,
    this.emailAddresses,
    this.avatar,
    this.postalAddresses,
    this.organizationInfo,
    this.birthday,
    this.notes,
    this.websiteURLs,
  });

  /// Creates a [Contact] object from a map returned by the native platform.
  factory Contact.fromMap(Map<dynamic, dynamic> map) => Contact(
        fullName: map['fullName'] as String?,
        phoneNumbers: (map['phoneNumbers'] as List<dynamic>?)?.cast<String>(),
        workPhoneNumber: map['workPhoneNumber'] as String?,
        homePhoneNumber: map['homePhoneNumber'] as String?,
        mobilePhoneNumber: map['mobilePhoneNumber'] as String?,
        selectedPhoneNumber: map['selectedPhoneNumber'] as String?,
        emailAddresses: (map['emailAddresses'] as List<dynamic>?)
            ?.map((e) => EmailAddress.fromMap(e as Map<dynamic, dynamic>))
            .toList(),
        avatar: map['avatar'] as String?,
        postalAddresses: (map['postalAddresses'] as List<dynamic>?)
            ?.map((e) => PostalAddress.fromMap(e as Map<dynamic, dynamic>))
            .toList(),
        organizationInfo: map['organizationInfo'] != null
            ? OrganizationInfo.fromMap(
                map['organizationInfo'] as Map<dynamic, dynamic>)
            : null,
        birthday: map['birthday'] as String?,
        notes: map['notes'] as String?,
        websiteURLs: (map['websiteURLs'] as List<dynamic>?)?.cast<String>(),
      );

  /// The full name of the contact.
  final String? fullName;

  /// All phone numbers associated with this contact.
  final List<String>? phoneNumbers;

  /// The contact's work phone number, if available.
  final String? workPhoneNumber;

  /// The contact's home phone number, if available.
  final String? homePhoneNumber;

  /// The contact's mobile phone number, if available.
  final String? mobilePhoneNumber;

  /// The phone number specifically selected by the user.
  final String? selectedPhoneNumber;

  /// A list of the contact's email addresses with labels.
  final List<EmailAddress>? emailAddresses;

  /// The contact's avatar image encoded in Base64, or `null` if unavailable.
  final String? avatar;

  /// The list of postal addresses (home, work, etc.) associated with the contact.
  final List<PostalAddress>? postalAddresses;

  /// The organization details of the contact, including company and job title.
  final OrganizationInfo? organizationInfo;

  /// The contact's birthday, formatted as an ISO 8601 string, or `null`.
  final String? birthday;

  /// Additional notes saved in the contact's profile.
  final String? notes;

  /// A list of website URLs associated with this contact.
  final List<String>? websiteURLs;

  @override
  String toString() =>
      'Contact(fullName: $fullName, phoneNumbers: $phoneNumbers, selectedPhoneNumber: $selectedPhoneNumber, '
      'homePhoneNumber: $homePhoneNumber, mobilePhoneNumber: $mobilePhoneNumber, workPhoneNumber: $workPhoneNumber, '
      'emailAddresses: $emailAddresses, avatar: ${avatar != null ? '[data]' : null}, '
      'postalAddresses: $postalAddresses, organizationInfo: $organizationInfo, '
      'birthday: $birthday, notes: $notes, websiteURLs: $websiteURLs)';
}

/// Represents an email address with an optional label such as "home" or "work".
class EmailAddress {
  /// Creates an [EmailAddress] with an email and optional label.
  EmailAddress({this.email, this.label});

  /// Creates an [EmailAddress] instance from a map returned by the native platform.
  factory EmailAddress.fromMap(Map<dynamic, dynamic> map) => EmailAddress(
        email: map['email'] as String?,
        label: map['label'] as String?,
      );

  /// The email address value.
  final String? email;

  /// The label describing the email type (e.g. "home", "work").
  final String? label;

  @override
  String toString() => '$email ($label)';
}

/// Represents a structured postal address, such as a home or work address.
class PostalAddress {
  /// Creates a [PostalAddress] with individual components.
  PostalAddress({
    this.street,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.label,
  });

  /// Creates a [PostalAddress] instance from a map returned by the native platform.
  factory PostalAddress.fromMap(Map<dynamic, dynamic> map) => PostalAddress(
        street: map['street'] as String?,
        city: map['city'] as String?,
        state: map['state'] as String?,
        postalCode: map['postalCode'] as String?,
        country: map['country'] as String?,
        label: map['label'] as String?,
      );

  /// The street name and house number.
  final String? street;

  /// The city or locality name.
  final String? city;

  /// The state, province, or region.
  final String? state;

  /// The postal or ZIP code.
  final String? postalCode;

  /// The country name.
  final String? country;

  /// The label describing this address (e.g. "home", "work").
  final String? label;

  @override
  String toString() => '$street, $city, $state $postalCode, $country ($label)';
}

/// Represents an organization associated with the contact.
class OrganizationInfo {
  /// Creates an [OrganizationInfo] containing company and job title details.
  OrganizationInfo({this.company, this.jobTitle});

  /// Creates an [OrganizationInfo] instance from a map returned by the native platform.
  factory OrganizationInfo.fromMap(Map<dynamic, dynamic> map) =>
      OrganizationInfo(
        company: map['company'] as String?,
        jobTitle: map['jobTitle'] as String?,
      );

  /// The company name the contact is associated with.
  final String? company;

  /// The contact's job title or role within the company.
  final String? jobTitle;

  @override
  String toString() => '$company, $jobTitle';
}
