//
//  AppDelegate.swift
//  GoMailerExample
//
//  Created by GoMailer Team on 10/03/2025.
//  Copyright © 2025 GoMailer Ltd. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configure Firebase
        FirebaseApp.configure()
        
        // Set up notifications
        setupNotifications()
        
        // Setup navigation
        setupInitialViewController()
        
        return true
    }
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { granted, error in
                if granted {
                    print("✅ Notification permission granted")
                } else {
                    print("❌ Notification permission denied: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        )
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    private func setupInitialViewController() {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let configViewController = ConfigurationViewController()
        let navigationController = UINavigationController(rootViewController: configViewController)
        
        // Configure navigation bar appearance
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.tintColor = UIColor.systemBlue
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    // MARK: - Remote Notifications
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("✅ Device Token: \(token)")
        
        // Store device token for use in GoMailer SDK
        NotificationCenter.default.post(name: .deviceTokenReceived, object: token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register for notifications: \(error.localizedDescription)")
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("📱 [AppDelegate] Notification will present: \(notification.request.content.title)")
        
        // Handle foreground notifications - show alert, play sound, and update badge
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("📬 Notification clicked: \(userInfo)")
        
        // Handle notification click
        NotificationCenter.default.post(name: .notificationClicked, object: userInfo)
        
        completionHandler()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let notificationClicked = Notification.Name("notificationClicked")
}