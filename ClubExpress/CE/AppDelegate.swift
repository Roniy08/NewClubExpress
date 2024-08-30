//
//  AppDelegate.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 14/12/2018.
//  
//

//last updated on 28 march by ronit
import UIKit
import SwinjectStoryboard
import Firebase
import CoreBluetooth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    weak var delegate: SettingsDelegate?
    var notificationsUtil = NotificationsUtil()
 
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        notificationsUtil.configureNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
        UserDefaults.standard.set("true", forKey: "isInitialLoad")
        UserDefaults.standard.set("0", forKey: "otherAppUnreadCount")
//        Terminal.setTokenProvider(APIClient.shared)

//        UserDefaults.standard.set("", forKey: "orgId")
        return true
    }
    func applicationWillTerminate(_ application: UIApplication) {
        // add here user info value before reset to production for tester
//        if let myString = MembershipAPIRouter.serverUrlInfo {
//
//            if  myString != "Production"
//            {
//                self.delegate?.forceLogoutForServer()
//                let serverUrlType = ""
//                MembershipAPIRouter.serverUrlInfo = serverUrlType
//                MembershipAPIRouter.processServerUrl()
//            }
//            
//        }
       
        // Perform any final cleanup tasks before the app is terminated.
    }
}
