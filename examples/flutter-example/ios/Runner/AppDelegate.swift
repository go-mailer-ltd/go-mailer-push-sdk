import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Forward device token to the GoMailer plugin via NotificationCenter so the plugin
  // can resolve the pending method channel result and send the token to the server.
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    print("AppDelegate: Got device token")
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
    print("AppDelegate: Failed to register - \(error)")
    NotificationCenter.default.post(
      name: NSNotification.Name("GoMailerDidFailToRegisterForRemoteNotifications"),
      object: nil,
      userInfo: ["error": error]
    )
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
}
