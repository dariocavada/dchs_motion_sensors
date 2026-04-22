#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint motion_sensors.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'dchs_motion_sensors'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for accessing the Android and iOS accelerometer gyroscope and magnetometer sensors.'
  s.description      = <<-DESC
Flutter plugin for accessing Android and iOS motion sensors, including
accelerometer, gyroscope, magnetometer, and orientation streams.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'dchs_motion_sensors/Sources/dchs_motion_sensors/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
