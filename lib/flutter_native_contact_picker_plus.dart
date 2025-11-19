import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_contact_picker_plus/model/contact_model.dart';

class FlutterContactPickerPlus {
  static const MethodChannel _channel =
      MethodChannel('flutter_native_contact_picker_plus');

  /// Method to call native code and get a single contact's details.
  Future<Contact?> selectContact() async {
    final Map<dynamic, dynamic>? result =
        await _channel.invokeMethod('selectContact');
    if (result == null) {
      return null;
    }
    return Contact.fromMap(result);
  }

  /// Method to call native code and get multiple contacts' details (iOS only).
  Future<List<Contact>?> selectContacts() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      throw UnimplementedError('selectContacts is only supported on iOS');
    }
    final List<dynamic>? result = await _channel.invokeMethod('selectContacts');
    return result?.map((e) => Contact.fromMap(e)).toList();
  }

  /// Method to call native code and select a specific phone number from a contact.
  Future<Contact?> selectPhoneNumber() async {
    final Map<dynamic, dynamic>? result =
        await _channel.invokeMethod('selectPhoneNumber');
    if (result == null) {
      return null;
    }
    return Contact.fromMap(result);
  }
}
