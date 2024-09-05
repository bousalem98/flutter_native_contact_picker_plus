import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_native_contact_picker_plus_method_channel.dart';

abstract class FlutterNativeContactPickerPlusPlatform extends PlatformInterface {
  /// Constructs a FlutterNativeContactPickerPlusPlatform.
  FlutterNativeContactPickerPlusPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterNativeContactPickerPlusPlatform _instance = MethodChannelFlutterNativeContactPickerPlus();

  /// The default instance of [FlutterNativeContactPickerPlusPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterNativeContactPickerPlus].
  static FlutterNativeContactPickerPlusPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterNativeContactPickerPlusPlatform] when
  /// they register themselves.
  static set instance(FlutterNativeContactPickerPlusPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
