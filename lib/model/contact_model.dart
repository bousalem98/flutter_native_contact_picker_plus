/// Represents a contact selected by the user.
class Contact {
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

  final String? fullName;
  final List<String>? phoneNumbers;
  final String? workPhoneNumber;
  final String? homePhoneNumber;
  final String? mobilePhoneNumber;
  final String? selectedPhoneNumber;
  final List<EmailAddress>? emailAddresses;
  final String? avatar; // Base64-encoded image or null
  final List<PostalAddress>? postalAddresses;
  final OrganizationInfo? organizationInfo;
  final String? birthday; // ISO 8601 date string or null
  final String? notes;
  final List<String>? websiteURLs;

  @override
  String toString() =>
      'Contact(fullName: $fullName, phoneNumbers: $phoneNumbers, selectedPhoneNumber: $selectedPhoneNumber, '
      'homePhoneNumber: $homePhoneNumber, mobilePhoneNumber: $mobilePhoneNumber, workPhoneNumber: $workPhoneNumber, '
      'emailAddresses: $emailAddresses, avatar: ${avatar != null ? '[data]' : null}, '
      'postalAddresses: $postalAddresses, organizationInfo: $organizationInfo, '
      'birthday: $birthday, notes: $notes, websiteURLs: $websiteURLs)';
}

/// Represents an email address with a label.
class EmailAddress {
  EmailAddress({this.email, this.label});

  factory EmailAddress.fromMap(Map<dynamic, dynamic> map) => EmailAddress(
        email: map['email'] as String?,
        label: map['label'] as String?,
      );

  final String? email;
  final String? label;

  @override
  String toString() => '$email ($label)';
}

/// Represents a postal address.
class PostalAddress {
  PostalAddress({
    this.street,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.label,
  });

  factory PostalAddress.fromMap(Map<dynamic, dynamic> map) => PostalAddress(
        street: map['street'] as String?,
        city: map['city'] as String?,
        state: map['state'] as String?,
        postalCode: map['postalCode'] as String?,
        country: map['country'] as String?,
        label: map['label'] as String?,
      );

  final String? street;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? label;

  @override
  String toString() => '$street, $city, $state $postalCode, $country ($label)';
}

/// Represents organization information.
class OrganizationInfo {
  OrganizationInfo({this.company, this.jobTitle});

  factory OrganizationInfo.fromMap(Map<dynamic, dynamic> map) =>
      OrganizationInfo(
        company: map['company'] as String?,
        jobTitle: map['jobTitle'] as String?,
      );

  final String? company;
  final String? jobTitle;

  @override
  String toString() => '$company, $jobTitle';
}
