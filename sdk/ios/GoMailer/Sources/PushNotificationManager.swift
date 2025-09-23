import Foundation
import UserNotifications
import UIKit

/// Push notification manager for handling device token registration
class PushNotificationManager: NSObject {
    
    weak var delegate: PushNotificationManagerDelegate?
    
    // MARK: - Public Methods
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted, error)
            }
        }
    }
    
    func getNotificationSettings(completion: @escaping (UNNotificationSettings) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings)
            }
        }
    }
}

// MARK: - PushNotificationManagerDelegate

protocol PushNotificationManagerDelegate: AnyObject {
    func didReceiveDeviceToken(_ token: String)
    func didFailToRegisterForRemoteNotifications(_ error: Error)
    func didReceiveNotification(_ notification: UNNotification)
    func didReceiveNotificationResponse(_ response: UNNotificationResponse)
}

// MARK: - UNUserNotificationCenterDelegate

extension PushNotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        delegate?.didReceiveNotification(notification)
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        delegate?.didReceiveNotificationResponse(response)
        completionHandler()
    }
}
