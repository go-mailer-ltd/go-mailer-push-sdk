Pod::Spec.new do |spec|
  spec.name         = "GoMailerPushSDK"
  spec.version      = "1.0.0"
  spec.summary      = "Receive push notifications from Go-Mailer in your iOS app"
  spec.description  = <<-DESC
    Go-Mailer Push SDK for iOS handles device registration, user identification, 
    and notification click tracking. Go-Mailer takes care of sending the 
    notifications - you just integrate our helper functions at the right time.
  DESC

  spec.homepage     = "https://github.com/go-mailer-ltd/go-mailer-push-sdk"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Go Mailer Team" => "support@gomailer.com" }

  spec.platform     = :ios, "10.0"
  spec.swift_version = "5.0"

  spec.source       = { :git => "https://github.com/go-mailer-ltd/go-mailer-push-sdk.git", :tag => "v#{spec.version}" }
  spec.source_files = "sdk/ios/GoMailer/Sources/**/*.swift"

  spec.frameworks   = "UIKit", "UserNotifications", "Foundation"
  spec.requires_arc = true

  # Optional Firebase dependencies - users can include these in their main project
  # spec.dependency "Firebase/Core"
  # spec.dependency "Firebase/Messaging"
  
  spec.documentation_url = "https://docs.go-mailer.com/ios"
end