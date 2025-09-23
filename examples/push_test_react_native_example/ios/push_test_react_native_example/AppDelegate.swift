import UIKit
import React
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, RCTBridgeDelegate, UNUserNotificationCenterDelegate {
  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    let bridge = RCTBridge(delegate: self, launchOptions: launchOptions)!
    
    let rootView = RCTRootView(
      bridge: bridge,
      moduleName: "push_test_react_native_example",
      initialProperties: nil
    )

    window = UIWindow(frame: UIScreen.main.bounds)
    let rootViewController = UIViewController()
    rootViewController.view = rootView
    window?.rootViewController = rootViewController
    window?.makeKeyAndVisible()
    
    // Set up notification delegate
    UNUserNotificationCenter.current().delegate = self

    return true
  }
  
  // MARK: - RCTBridgeDelegate
  
  func sourceURL(for bridge: RCTBridge!) -> URL! {
    #if DEBUG
      return RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
    #else
      return Bundle.main.url(forResource: "main", withExtension: "jsbundle")
    #endif
  }
  
  // MARK: - Push Notification Methods
  
  func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    print("🔵 AppDelegate: didRegisterForRemoteNotificationsWithDeviceToken")
    
    // Send event to React Native
    if let bridge = RCTBridge.current() {
      bridge.eventDispatcher().sendAppEvent(withName: "GoMailerDidRegisterForRemoteNotifications", body: ["deviceToken": deviceToken])
    }
  }
  
  func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("🔴 AppDelegate: didFailToRegisterForRemoteNotificationsWithError: \(error)")
    
    // Send event to React Native
    if let bridge = RCTBridge.current() {
      bridge.eventDispatcher().sendAppEvent(withName: "GoMailerDidFailToRegisterForRemoteNotifications", body: ["error": error.localizedDescription])
    }
  }
  
  // MARK: - UNUserNotificationCenterDelegate
  
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    print("🔵 AppDelegate: Notification received while app is in foreground")
    completionHandler([.banner, .sound, .badge])
  }
  
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    print("🔵 AppDelegate: User tapped notification")
    
    // Extract notification data
    let notification = response.notification
    let userInfo = notification.request.content.userInfo
    let notificationId = userInfo["notification_id"] as? String ?? "unknown"
    let title = notification.request.content.title ?? "Unknown"
    let body = notification.request.content.body ?? ""
    
    print("🔵 AppDelegate: Notification details - ID: \(notificationId), Title: \(title)")
    
    // Send event to React Native for SDK to handle
    if let bridge = RCTBridge.current() {
      let properties: [String: Any] = [
        "notification_id": notificationId,
        "notification_title": title,
        "notification_body": body,
        "action_identifier": response.actionIdentifier,
        "user_info": userInfo,
        "click_timestamp": ISO8601DateFormatter().string(from: Date())
      ]
      
      bridge.eventDispatcher().sendAppEvent(withName: "GoMailerNotificationClicked", body: [
        "eventName": "notification_clicked",
        "properties": properties
      ])
    }
    
    completionHandler()
  }
}
