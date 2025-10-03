Pod::Spec.new do |spec|
  spec.name         = "GoMailerPushSDK"
  spec.version      = "1.3.1"
  spec.summary      = "Receive push notifications from Go-Mailer in your iOS app"
  spec.description  = <<-DESC
    Go-Mailer Push SDK for iOS handles device registration, user identification, 
    and notification click tracking. Go-Mailer takes care of sending the 
    notifications - you just integrate our helper functions at the right time.
  DESC

  spec.homepage     = "https://docs.go-mailer.com/ios"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Go Mailer Team" => "support@gomailer.com" }

  spec.platform     = :ios, "12.0"
  spec.swift_version = "5.0"

  spec.source       = { :git => "https://github.com/go-mailer-ltd/go-mailer-push-sdk.git", :tag => "v#{spec.version}" }
  # Source files path is relative to the podspec location (sdk/ios)
  # Actual sources live at sdk/ios/GoMailer/Sources/*.swift
  # Use a recursive glob so whether the podspec is evaluated from repo root (trunk) or this subfolder (local lint)
  # it still resolves the Swift sources under sdk/ios/GoMailer/Sources
  spec.source_files = "**/GoMailer/Sources/**/*.swift"

  spec.frameworks   = "UIKit", "UserNotifications", "Foundation"
  spec.requires_arc = true

  # Firebase dependencies
  spec.dependency "Firebase/Core", "~> 10.25.0"
  spec.dependency "Firebase/Messaging", "~> 10.25.0"
  
  spec.documentation_url = "https://docs.go-mailer.com/ios"
end