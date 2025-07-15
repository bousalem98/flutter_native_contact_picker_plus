Pod::Spec.new do |s|
  s.name             = 'flutter_native_contact_picker_plus'
  s.version          = '0.0.2'
  s.summary          = 'An enhanced version of flutter_native_contact_picker for selecting contacts from the address book.'
  s.description      = <<-DESC
An enhanced version of flutter_native_contact_picker for selecting contacts from the address book.
                       DESC
  s.homepage         = 'https://github.com/bousalem98/flutter_native_contact_picker_plus'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Mohamed Salem Bousalem' => 'hkouma2011@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'flutter_native_contact_picker_plus/Sources/flutter_native_contact_picker_plus/**/*.swift'
  
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'flutter_native_contact_picker_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
