import 'package:flutter_native_contact_picker_plus/model/contact_model.dart';
import 'package:flutter_test/flutter_test.dart';
//import 'package:flutter_native_contact_picker_plus/flutter_native_contact_picker_plus.dart';
import 'package:flutter_native_contact_picker_plus/flutter_native_contact_picker_plus_platform_interface.dart';
import 'package:flutter_native_contact_picker_plus/flutter_native_contact_picker_plus_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterNativeContactPickerPlusPlatform
    with MockPlatformInterfaceMixin
    implements FlutterNativeContactPickerPlusPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Contact?> selectContact() {
    //  implement selectContact
    throw UnimplementedError();
  }

  @override
  Future<List<Contact>?> selectContacts() {
    // implement selectContacts
    throw UnimplementedError();
  }

  @override
  Future<Contact?> selectPhoneNumber() {
    // implement selectPhoneNumber
    throw UnimplementedError();
  }
}

void main() {
  final FlutterNativeContactPickerPlusPlatform initialPlatform =
      FlutterNativeContactPickerPlusPlatform.instance;

  test('$MethodChannelFlutterNativeContactPickerPlus is the default instance',
      () {
    expect(initialPlatform,
        isInstanceOf<MethodChannelFlutterNativeContactPickerPlus>());
  });

  test('getPlatformVersion', () async {
    /* FlutterNativeContactPickerPlus flutterNativeContactPickerPlusPlugin =
        FlutterNativeContactPickerPlus();
    MockFlutterNativeContactPickerPlusPlatform fakePlatform =
        MockFlutterNativeContactPickerPlusPlatform();
    FlutterNativeContactPickerPlusPlatform.instance = fakePlatform;

    expect(
        await flutterNativeContactPickerPlusPlugin.getPlatformVersion(), '42');*/
  });
}
