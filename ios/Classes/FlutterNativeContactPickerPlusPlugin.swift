import Flutter
import UIKit
import ContactsUI

// Base handler class
class PickerHandler: NSObject, CNContactPickerDelegate {
    var result: FlutterResult
    
    required init(result: @escaping FlutterResult) {
        self.result = result
        super.init()
    }
    
    @available(iOS 9.0, *)
    public func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        result(nil)
    }
}

// Handler for single contact selection
class SinglePickerHandler: PickerHandler {
    @available(iOS 9.0, *)
    public func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        var data = [String: Any]()
        data["fullName"] = CNContactFormatter.string(from: contact, style: .fullName)
        
        let numbers = contact.phoneNumbers.compactMap { $0.value.stringValue }
        data["phoneNumbers"] = numbers
        
        result(data)
    }
}

// Handler for multiple contacts selection
class MultiPickerHandler: PickerHandler {
    @available(iOS 9.0, *)
    public func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        var selectedContacts = [[String: Any]]()
        
        for contact in contacts {
            var contactInfo = [String: Any]()
            contactInfo["fullName"] = CNContactFormatter.string(from: contact, style: .fullName)
            
            let numbers = contact.phoneNumbers.compactMap { $0.value.stringValue }
            contactInfo["phoneNumbers"] = numbers
            
            selectedContacts.append(contactInfo)
        }
        
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
      if("selectContact" == call.method || "selectContacts" == call.method) {
        if(_delegate != nil) {
            _delegate!.result(FlutterError(code: "multiple_requests", message: "Cancelled by a second request.", details: nil));
            _delegate = nil;
          }

          if #available(iOS 9.0, *){
              let single = call.method == "selectContact";
              _delegate = single ? SinglePickerHandler(result: result) : MultiPickerHandler(result: result);
              let contactPicker = CNContactPickerViewController()
              contactPicker.delegate = _delegate
              contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
              
              // find proper keyWindow
              var keyWindow: UIWindow? = nil
              if #available(iOS 13, *) {
                  keyWindow = UIApplication.shared.connectedScenes.filter {
                      $0.activationState == .foregroundActive
                  }.compactMap { $0 as? UIWindowScene
                  }.first?.windows.filter({ $0.isKeyWindow}).first
              } else {
                  keyWindow = UIApplication.shared.keyWindow
              }
              
              let viewController = keyWindow?.rootViewController
              viewController?.present(contactPicker, animated: true, completion: nil)
          }
      }
       else
          {
              result(FlutterMethodNotImplemented)
          }
    }

}
