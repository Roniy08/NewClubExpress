//
//  NotificationsUtil.swift
//  ClubExpress
//
//  Created by Joe Benton on 19/03/2019.
//  Copyright © 2019 Zeta. All rights reserved.
//

import Foundation
import Firebase
import UserNotifications
import FirebaseMessaging

class NotificationsUtil: NSObject {
    func configureNotifications() {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
    }
    
    func handleReceivedNotification(userInfo: Dictionary<String,Any>) {
        let orgID = userInfo["org_id"] as? String ?? ""
        let navigateUrl = userInfo["destination_url"] as? String ?? ""
        let orgUnreadCountsString = userInfo["org_unread_counts"] as? String ?? ""
        let orgUnreadCountsDict = createDictionaryFromJsonString(string: orgUnreadCountsString)
            
        let receivedNotification = ReceivedNotification(orgID: orgID, navigateUrl: navigateUrl, orgUnreadCounts: orgUnreadCountsDict)
        if navigateUrl != ""
        {
            guard let appDelegate = UIApplication.shared.delegate else { return }
            if let organisationWrapperVC = appDelegate.window??.rootViewController as? OrganisationWrapperViewController {
                //Handle notification in organisation wrapper
                organisationWrapperVC.handleReceivedNotification(notification: receivedNotification)
            } else {
                //Change page to notif org switcher and then handle notification
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let notifOrgSwticherVC = storyboard.instantiateViewController(withIdentifier: "notifOrgSwitcherVC") as? NotifOrgSwitcherViewController {
                    notifOrgSwticherVC.receivedNotification = receivedNotification
                    appDelegate.window??.rootViewController = notifOrgSwticherVC
                }
            }
          }
        else
            {
                print("no navigation url found")
            }
        }

    
    func createDictionaryFromJsonString(string: String) -> Dictionary<String,String> {
        if let data = string.data(using: .utf8) {
            do {
                let dataDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
                if let dataDict = dataDict { return dataDict } else { return [:] }
            } catch let error {
                print(error)
            }
        }
        return [:]
    }
}

extension NotificationsUtil: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("will present notification")
        
        //save unread count for selected organisation
        if let userInfo = notification.request.content.userInfo as? Dictionary<String, Any> {
            print(userInfo)
            if let orgUnreadCountsString = userInfo["org_unread_counts"] as? String {
                if (userInfo["badge"] != nil){
                    UIApplication.shared.applicationIconBadgeNumber = Int((userInfo["badge"] ?? "0") as! String) ?? 0
                }
                let orgUnreadCountsDict = createDictionaryFromJsonString(string: orgUnreadCountsString)
                let orgId = userInfo["org_id"] as! String
                var otherAppUnreadCount = 0
                
                if(orgId == "0"){
                    let orgIdFromStorage = UserDefaults.standard.string(forKey: "orgId") ?? "0"
                    for (key, value) in orgUnreadCountsDict{
                        if(key != orgIdFromStorage){
                            otherAppUnreadCount += Int(value as String) ?? 0
                        }
                    }
                }
                else{
                    for (key, value) in orgUnreadCountsDict{
                        if(key != orgId ){
                            otherAppUnreadCount += Int(value as String) ?? 0
                        }
                    }
                }
               
                var totalCount = 0
                for org in orgUnreadCountsDict ?? [:] {
                    totalCount += Int(org.value) ?? 0
                }
                
                let otherAppNotificationDict:[String: Int] = ["count": otherAppUnreadCount]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setOtherAppNotificationCount"), object: nil, userInfo: otherAppNotificationDict)
                UserDefaults.standard.set("\(otherAppUnreadCount)", forKey: "otherAppUnreadCount")
                
                
                
                
                
                let totalAppNotificationCountDict:[String: Int] = ["count": totalCount]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateCount"), object: nil, userInfo: totalAppNotificationCountDict)
                
                UIApplication.shared.applicationIconBadgeNumber = totalCount

                guard let appDelegate = UIApplication.shared.delegate else { return }
                if let organisationWrapperVC = appDelegate.window??.rootViewController as? OrganisationWrapperViewController {
                    organisationWrapperVC.saveUnreadNotificationsCount(unreadCounts: orgUnreadCountsDict)
                }
            }
           
        }
        
        completionHandler([.alert,.badge,.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("received apns notificaiton:")
        
        if let userInfo = response.notification.request.content.userInfo as? Dictionary<String,Any> {
            print(userInfo)
            handleReceivedNotification(userInfo: userInfo)
        }
        
        completionHandler()
    }
}

extension NotificationsUtil: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("token: \(fcmToken)")
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingDelegate) {
        print("received firebase message:")
        print(remoteMessage.description)
    }
    
    //...enable later to check notification....... apn token pass through this...........
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}
