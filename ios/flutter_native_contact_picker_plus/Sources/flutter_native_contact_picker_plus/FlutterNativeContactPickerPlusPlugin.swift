import ContactsUI
import Flutter
import UIKit
import os.log

class PickerHandler: NSObject, CNContactPickerDelegate {
    var result: FlutterResult

    required init(result: @escaping FlutterResult) {
        self.result = result
        super.init()
    }

    @available(iOS 9.0, *)
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        result(nil)
    }

    func mapPhoneLabel(_ label: String?) -> String {
        guard let label = label else { return "other" }
        switch label {
        case CNLabelPhoneNumberiPhone, CNLabelPhoneNumberMobile: return "mobile"
        case CNLabelPhoneNumberMain, CNLabelWork: return "work"
        case CNLabelHome: return "home"
        default: return "other"
        }
    }

    func mapLabel(_ label: String?) -> String {
        guard let label = label else { return "other" }
        switch label {
        case CNLabelHome: return "home"
        case CNLabelWork: return "work"
        case CNLabelOther: return "other"
        default: return "other"
        }
    }
}

class SinglePickerHandler: PickerHandler {
    @available(iOS 9.0, *)
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        result(processContact(contact))
    }

    func processContact(_ contact: CNContact) -> [String: Any?] {
        var data = [String: Any?]()

        // Basic info available without full contacts permission
        data["fullName"] = CNContactFormatter.string(from: contact, style: .fullName)
        data["contactId"] = contact.identifier
        data["lookupKey"] = contact.identifier

        // Get all phone numbers
        let phoneNumbers = contact.phoneNumbers.compactMap { $0.value.stringValue }
        data["phoneNumbers"] = phoneNumbers

        // Get phone types if available
        let phoneTypes = contact.phoneNumbers.map { mapPhoneLabel($0.label) }
        data["phoneType"] = phoneTypes.first ?? "other"

        // Initialize all fields with default values
        data["emailAddresses"] = []
        data["postalAddresses"] = []
        data["websiteURLs"] = []
        data["organizationInfo"] = nil
        data["birthday"] = nil
        data["notes"] = nil
        data["avatar"] = nil

        // Try to get additional info if permissions allow
        if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            // Emails
            let emails = contact.emailAddresses.map {
                ["email": $0.value as String, "label": mapLabel($0.label)]
            }
            data["emailAddresses"] = emails

            // Addresses
            let addresses = contact.postalAddresses.map { address in
                [
                    "street": address.value.street,
                    "city": address.value.city,
                    "state": address.value.state,
                    "postalCode": address.value.postalCode,
                    "country": address.value.country,
                    "label": mapLabel(address.label),
                ]
            }
            data["postalAddresses"] = addresses

            // Websites
            data["websiteURLs"] = contact.urlAddresses.map { $0.value as String }

            // Organization
            if !contact.organizationName.isEmpty || !contact.jobTitle.isEmpty {
                data["organizationInfo"] = [
                    "company": contact.organizationName,
                    "jobTitle": contact.jobTitle,
                ]
            }

            // Birthday
            if let birthday = contact.birthday,
                let date = Calendar.current.date(from: birthday)
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                data["birthday"] = formatter.string(from: date)
            }

            // Notes
            data["notes"] = contact.note

            // Avatar
            if let imageData = contact.imageData,
                let image = UIImage(data: imageData),
                let dataString = image.pngData()?.base64EncodedString()
            {
                data["avatar"] = dataString
            }
        }

        return data
    }
}

class PhonePickerHandler: PickerHandler {
    @available(iOS 9.0, *)
    func contactPicker(
        _ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty
    ) {
        guard contactProperty.key == CNContactPhoneNumbersKey,
            let phoneNumber = contactProperty.value as? CNPhoneNumber
        else {
            result(nil)
            return
        }

        var data = [String: Any?]()
        let contact = contactProperty.contact

        // Basic info available without full contacts permission
        data["fullName"] = CNContactFormatter.string(from: contact, style: .fullName)
        data["contactId"] = contact.identifier
        data["lookupKey"] = contact.identifier

        // Phone info
        data["selectedPhoneNumber"] = phoneNumber.stringValue
        data["phoneNumbers"] = [phoneNumber.stringValue]
        data["phoneType"] = mapPhoneLabel(contactProperty.label)

        // Initialize all other fields
        data["emailAddresses"] = []
        data["postalAddresses"] = []
        data["websiteURLs"] = []
        data["organizationInfo"] = nil
        data["birthday"] = nil
        data["notes"] = nil
        data["avatar"] = nil

        result(data)
    }
}

class MultiPickerHandler: PickerHandler {
    @available(iOS 9.0, *)
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        let selectedContacts = contacts.map {
            SinglePickerHandler(result: { _ in }).processContact($0)
        }
        result(selectedContacts)
    }
}

public class FlutterNativeContactPickerPlusPlugin: NSObject, FlutterPlugin {
    private var delegate: PickerHandler?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "flutter_native_contact_picker_plus",
            binaryMessenger: registrar.messenger()
        )
        let instance = FlutterNativeContactPickerPlusPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            self.handleOnMainThread(call, result: result)
        }
    }

    private func handleOnMainThread(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard #available(iOS 9.0, *) else {
            result(
                FlutterError(
                    code: "unsupported_os",
                    message: "iOS 9.0 or higher required",
                    details: nil
                ))
            return
        }

        switch call.method {
        case "selectContact", "selectContacts", "selectPhoneNumber":
            if let existingDelegate = self.delegate {
                existingDelegate.result(
                    FlutterError(
                        code: "multiple_requests",
                        message: "Cancelled by a second request",
                        details: nil
                    ))
            }

            let contactPicker = CNContactPickerViewController()

            switch call.method {
            case "selectContact":
                self.delegate = SinglePickerHandler(result: result)

            case "selectPhoneNumber":
                self.delegate = PhonePickerHandler(result: result)
                contactPicker.predicateForSelectionOfProperty = NSPredicate(
                    format: "key == 'phoneNumbers'"
                )

            case "selectContacts":
                self.delegate = MultiPickerHandler(result: result)
                contactPicker.predicateForEnablingContact = NSPredicate(
                    format: "phoneNumbers.@count > 0"
                )

            default:
                result(FlutterMethodNotImplemented)
                return
            }

            contactPicker.delegate = self.delegate

            // Only request basic fields that don't need permissions
            contactPicker.displayedPropertyKeys = [
                CNContactIdentifierKey,
                CNContactPhoneNumbersKey,
                CNContactGivenNameKey,
                CNContactFamilyNameKey,
            ]

            if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
                rootVC.present(contactPicker, animated: true)
            } else {
                result(
                    FlutterError(
                        code: "no_view_controller",
                        message: "Unable to find root view controller",
                        details: nil
                    ))
            }

        case "getPlatformVersion":
            result("iOS \(UIDevice.current.systemVersion)")

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
