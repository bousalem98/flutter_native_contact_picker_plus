import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_contact_picker_plus/model/contact_model.dart';

import 'flutter_native_contact_picker_plus_platform_interface.dart';

/// An implementation of [FlutterNativeContactPickerPlusPlatform] that uses method channels.
class MethodChannelFlutterNativeContactPickerPlus
    extends FlutterNativeContactPickerPlusPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel =
      const MethodChannel('flutter_native_contact_picker_plus');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<Contact?> selectContact() async {
    final Map<dynamic, dynamic>? result = await methodChannel
        .invokeMethod<Map<dynamic, dynamic>?>('selectContact');
    if (result == null) {
      return null;
    }
    return Contact.fromMap(result);
  }

  @override
  Future<List<Contact>?> selectContacts() async {
    final List<dynamic>? result =
        await methodChannel.invokeMethod<List<dynamic>?>('selectContacts');
    if (result == null) {
      return null;
    }
    return result.map((e) => Contact.fromMap(e)).toList();
  }

  @override
  Future<Contact?> selectPhoneNumber() async {
    final Map<dynamic, dynamic>? result = await methodChannel
        .invokeMethod<Map<dynamic, dynamic>?>('selectPhoneNumber');
    if (result == null) {
      return null;
    }
    return Contact.fromMap(result);
  }
}
