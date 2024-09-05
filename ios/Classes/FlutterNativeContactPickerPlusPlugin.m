#import "FlutterNativeContactPickerPlusPlugin.h"
#if __has_include(<flutter_native_contact_picker_plus/flutter_native_contact_picker_plus-Swift.h>)
#import <flutter_native_contact_picker_plus/flutter_native_contact_picker_plus-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_native_contact_picker_plus-Swift.h"
#endif

@implementation FlutterNativeContactPickerPlusPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterNativeContactPickerPlusPlugin registerWithRegistrar:registrar];
}
@end
