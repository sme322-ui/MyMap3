import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn
import Messages
import FirebaseMessaging
import UserNotifications
import OpenAI
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,MessagingDelegate,UNUserNotificationCenterDelegate {
    var window: UIWindow?
    
    let gIdConfiguration = GIDConfiguration(clientID: "1032708914109-7da9mot768l8pd1f3g6b3f1j66r61an5.apps.googleusercontent.com", serverClientID: "1032708914109")
   
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                     withError error: Error!) {
               if let error = error {
                   print("\(error.localizedDescription)")
                   // [START_EXCLUDE silent]
                   NotificationCenter.default.post(
                       name: Notification.Name(rawValue: "ToggleAuthUINotification"), object: nil, userInfo: nil)
                   // [END_EXCLUDE]
               }
           }
        
        func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
                      withError error: Error!) {
                // Perform any operations when the user disconnects from app here.
                // [START_EXCLUDE]
                NotificationCenter.default.post(
                    name: Notification.Name(rawValue: "ToggleAuthUINotification"),
                    object: nil,
                    userInfo: ["statusText": "User has disconnected."])
                // [END_EXCLUDE]
            }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        print(url)
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        GIDSignIn.sharedInstance.configuration = gIdConfiguration
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        let authOptions:UNAuthorizationOptions = [.alert,.sound,.badge]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions){(_,_) in}
        application.registerForRemoteNotifications()
        
     
               UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge])
        {(granted,error) in
            if granted{
                print("User Notification are allow")
            }else{
                print("User notification are not allow")
            }
            
        }
        let fm = FileManager.default
        
        let src = Bundle.main.path(forResource: "stations", ofType: "plist")
        
        let dst = NSHomeDirectory()+"/Documents/stations.plist"
        
        if !fm.fileExists(atPath: dst){
            try! fm.copyItem(atPath: src!, toPath: dst)
        }
        return true
        
        
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    @available(iOS 9.0, *)
    func application(
      _ application: UIApplication,
      open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]
    ) -> Bool {
    // Handle other custom URL types.

      // If not handled by this app, return false.
        GIDSignIn.sharedInstance.configuration = gIdConfiguration
        
        
        return GIDSignIn.sharedInstance.handle(url)
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Get Token:\(fcmToken)")
    }
    
    
    
}

