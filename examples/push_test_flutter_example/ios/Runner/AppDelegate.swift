import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    NotificationCenter.default.post(
      name: NSNotification.Name("GoMailerDidRegisterForRemoteNotifications"),
      object: nil,
      userInfo: ["deviceToken": deviceToken]
    )
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    NotificationCenter.default.post(
      name: NSNotification.Name("GoMailerDidFailToRegisterForRemoteNotifications"),
      object: nil,
      userInfo: ["error": error]
    )
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
}