//
//  AppDelegate.swift
//  Where is my Lego
//
//  Created by Filip Jabłoński on 15/04/2023.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    let notificationHandler = PushNotificationHandler()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {}
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("Device token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
        print("Received Remote notification: \(userInfo)")
        return .newData
    }
}

final class PushNotificationHandler: NSObject, UNUserNotificationCenterDelegate  {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Received notification: \(notification.description)")
        completionHandler([.banner, .sound, .badge, .list])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Received notification: \(response.description)")
        completionHandler()
    }

}
