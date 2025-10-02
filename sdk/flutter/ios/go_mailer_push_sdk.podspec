#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
#
Pod::Spec.new do |s|
  s.name             = 'go_mailer_push_sdk'
  s.version          = '1.3.0'
  s.summary          = 'GoMailer Push SDK for Flutter'
  s.description      = <<-DESC
A Flutter plugin for GoMailer Push Notifications.
                       DESC
  s.homepage         = 'https://go-mailer.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'GoMailer' => 'support@gomailer.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
