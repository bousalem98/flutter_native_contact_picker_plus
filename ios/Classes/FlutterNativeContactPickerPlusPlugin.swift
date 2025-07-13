import Flutter
import UIKit
import ContactsUI
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
}

class SinglePickerHandler: PickerHandler {
    @available(iOS 9.0, *)
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        result(processContact(contact))
    }
    
    func processContact(_ contact: CNContact) -> [String: Any?] {
        var data = [String: Any?]()
        
        // Full Name
        do {
            data["fullName"] = CNContactFormatter.string(from: contact, style: .fullName)
        } catch {
            os_log("Failed to read fullName: %@", log: .default, type: .error, error.localizedDescription)
            data["fullName"] = nil
        }
        
        // Phone Numbers
        do {
            let numbers = contact.phoneNumbers.map { ["number": $0.value.stringValue, "label": mapPhoneLabel($0.label)] }
            data["phoneNumbers"] = numbers.map { $0["number"] }
            data["phoneType"] = numbers.first?["label"] // Set phoneType to the first phone number's label
        } catch {
            os_log("Failed to read phoneNumbers: %@", log: .default, type: .error, error.localizedDescription)
            data["phoneNumbers"] = []
            data["phoneType"] = nil
        }
        
        // Email Addresses
        do {
            let emails = contact.emailAddresses.map { ["email": $0.value as String, "label": mapLabel($0.label)] }
            data["emailAddresses"] = emails
        } catch {
            os_log("Failed to read emailAddresses: %@", log: .default, type: .error, error.localizedDescription)
            data["emailAddresses"] = []
        }
        
        // Postal Addresses
        do {
            let addresses = contact.postalAddresses.map { address in
                [
                    "street": address.value.street,
                    "city": address.value.city,
                    "state": address.value.state,
                    "postalCode": address.value.postalCode,
                    "country": address.value.country,
                    "label": mapLabel(address.label)
                ]
            }
            data["postalAddresses"] = addresses
        } catch {
            os_log("Failed to read postalAddresses: %@", log: .default, type: .error, error.localizedDescription)
            data["postalAddresses"] = []
        }
        
        // Website URLs
        do {
            let websites = contact.urlAddresses.map { $0.value as String }
            data["websiteURLs"] = websites
        } catch {
            os_log("Failed to read websiteURLs: %@", log: .default, type: .error, error.localizedDescription)
            data["websiteURLs"] = []
        }
        
        // Organization Info
        do {
            let orgInfo = [
                "company": contact.organizationName,
                "jobTitle": contact.jobTitle
            ]
            data["organizationInfo"] = orgInfo.isEmpty ? nil : orgInfo
        } catch {
            os_log("Failed to read organizationInfo: %@", log: .default, type: .error, error.localizedDescription)
            data["organizationInfo"] = nil
        }
        
        // Birthday
        do {
            if let birthday = contact.birthday {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                data["birthday"] = formatter.string(from: birthday)
            } else {
                data["birthday"] = nil
            }
        } catch {
            os_log("Failed to read birthday: %@", log: .default, type: .error, error.localizedDescription)
            data["birthday"] = nil
        }
        
        // Notes
        do {
            if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
                data["notes"] = contact.note
            } else {
                os_log("Notes require contacts authorization", log: .default, type: .error)
                data["notes"] = nil
            }
        } catch {
            os_log("Failed to read notes: %@", log: .default, type: .error, error.localizedDescription)
            data["notes"] = nil
        }
        
        // Avatar
        do {
            if let imageData = contact.imageData, let image = UIImage(data: imageData) {
                let dataString = image.pngData()?.base64EncodedString()
                data["avatar"] = dataString
            } else {
                data["avatar"] = nil
            }
        } catch {
            os_log("Failed to read avatar: %@", log: .default, type: .error, error.localizedDescription)
            data["avatar"] = nil
        }
        
        // Contact ID and Lookup Key
        do {
            data["contactId"] = contact.identifier
            data["lookupKey"] = contact.identifier // iOS doesn't have a direct lookupKey; use identifier
        } catch {
            os_log("Failed to read contactId/lookupKey: %@", log: .default, type: .error, error.localizedDescription)
            data["contactId"] = nil
            data["lookupKey"] = nil
        }
        
        return data
    }
    
    private func mapPhoneLabel(_ label: String?) -> String {
        guard let label = label else { return "other" }
        switch label {
        case CNLabelPhoneNumberiPhone, CNLabelPhoneNumberMobile: return "mobile"
        case CNLabelPhoneNumberMain, CNLabelWork: return "work"
        case CNLabelHome: return "home"
        default: return "other"
        }
    }
    
    private func mapLabel(_ label: String?) -> String {
        guard let label = label else { return "other" }
        switch label {
        case CNLabelHome: return "home"
        case CNLabelWork: return "work"
        case CNLabelOther: return "other"
        default: return "other"
        }
    }
}

class PhonePickerHandler: PickerHandler {
    @available(iOS 9.0, *)
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        guard contactProperty.key == CNContactPhoneNumbersKey,
              let phoneNumber = contactProperty.value as? CNPhoneNumber else {
            result(nil)
            return
        }
        
        var data = [String: Any?]()
        do {
            data["fullName"] = CNContactFormatter.string(from: contactProperty.contact, style: .fullName)
        } catch {
            os_log("Failed to read fullName: %@", log: .default, type: .error, error.localizedDescription)
            data["fullName"] = nil
        }
        
        do {
            data["selectedPhoneNumber"] = phoneNumber.stringValue
            data["phoneNumbers"] = [phoneNumber.stringValue]
            data["phoneType"] = mapPhoneLabel(contactProperty.label)
        } catch {
            os_log("Failed to read phone number: %@", log: .default, type: .error, error.localizedDescription)
            data["selectedPhoneNumber"] = nil
            data["phoneNumbers"] = []
            data["phoneType"] = nil
        }
        
        // Initialize other fields
        data["emailAddresses"] = []
        data["postalAddresses"] = []
        data["websiteURLs"] = []
        data["organizationInfo"] = nil
        data["birthday"] = nil
        data["notes"] = nil
        data["avatar"] = nil
        data["contactId"] = nil
        data["lookupKey"] = nil
        
        result(data)
    }
}

class MultiPickerHandler: PickerHandler {
    @available(iOS 9.0, *)
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        let selectedContacts = contacts.map { SinglePickerHandler(result: { _ in }).processContact($0) }
        result(selectedContacts)
    }
}

public class SwiftFlutterNativeContactPickerPlusPlugin: NSObject, FlutterPlugin {
    var delegate: PickerHandler?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_native_contact_picker_plus", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterNativeContactPickerPlusPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard #available(iOS 9.0, *) else {
            result(FlutterError(code: "unsupported_os", message: "iOS 9.0 or higher required", details: nil))
            return
        }
        
        switch call.method {
        case "selectContact", "selectContacts", "selectPhoneNumber":
            if delegate != nil {
                delegate?.result(FlutterError(code: "multiple_requests", message: "Cancelled by a second request.", details: nil))
                delegate = nil
            }
            
            let contactPicker = CNContactPickerViewController()
            contactPicker.delegate = {
                switch call.method {
                case "selectContact":
                    return SinglePickerHandler(result: result)
                case "selectPhoneNumber":
                    let handler = PhonePickerHandler(result: result)
                    contactPicker.predicateForSelectionOfProperty = NSPredicate(format: "key == 'phoneNumbers'")
                    return handler
                case "selectContacts":
                    contactPicker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0")
                    return MultiPickerHandler(result: result)
                default:
                    return nil
                }
            }()
            
            contactPicker.displayedPropertyKeys = [
                CNContactPhoneNumbersKey,
                CNContactEmailAddressesKey,
                CNContactPostalAddressesKey,
                CNContactUrlAddressesKey,
                CNContactOrganizationNameKey,
                CNContactJobTitleKey,
                CNContactBirthdayKey,
                CNContactNoteKey,
                CNContactImageDataKey,
                CNContactIdentifierKey
            ]
            
            var keyWindow: UIWindow?
            if #available(iOS 13, *) {
                keyWindow = UIApplication.shared.connectedScenes
                    .filter { $0.activationState == .foregroundActive }
                    .compactMap { $0 as? UIWindowScene }
                    .first?.windows
                    .filter { $0.isKeyWindow }
                    .first
            } else {
                keyWindow = UIApplication.shared.keyWindow
            }
            
            guard let viewController = keyWindow?.rootViewController else {
                result(FlutterError(code: "no_view_controller", message: "Unable to find root view controller", details: nil))
                return
            }
            
            delegate = contactPicker.delegate as? PickerHandler
            viewController.present(contactPicker, animated: true, completion: nil)
            
        case "getPlatformVersion":
            result("iOS \(UIDevice.current.systemVersion)")
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}