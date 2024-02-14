//
//  Login.swift
//  MyMap4
//
//  Created by Mongyan on 2023/5/9.
//
import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import SwiftUI
import GoogleSignIn
import Firebase
import FirebaseMessaging
class Login:UIViewController{
    var mAuth:Auth!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var account: UITextField!
    @IBOutlet weak var loginStatus:UITextView!
    @IBOutlet weak var signInButton: GIDSignInButton!
    enum SignInState {
        case signedIn
        case signedOut
    }
    @Published var state: SignInState = .signedOut
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: NSError!) {
        
        
        
        
        // 1
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                authenticateUser(for: user, with: error)
                state = .signedIn
            }
        } else {
            // 2
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            
            // 3
            let configuration = GIDConfiguration(clientID: clientID)
            
            // 4
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
            
            // 5
            
        }
        
    }
    
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
        // 1
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        
    }
    
    func signOut() {
        // 1
        GIDSignIn.sharedInstance.signOut()
        
        do {
            // 2
            try Auth.auth().signOut()
            
            state = .signedOut
        } catch {
            print(error.localizedDescription)
        }
    }
    @IBOutlet weak var loginMessage: UILabel!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mAuth = Auth.auth()
        Auth.auth().signInAnonymously{(user,error) in
            if error != nil{
                print(error?.localizedDescription as Any)
            }else{
                print(user.debugDescription)
            }
        }
        
        Auth.auth().createUser(withEmail: "subendon@yuntech.edu.tw", password: "01A3b7404933") { result, error in
            
            guard let user = result?.user,
                  error == nil else {
                print(error?.localizedDescription as Any)
                return
            }
            print(user.email as Any, user.uid)
        }
        Auth.auth().signIn(withEmail: "subendon@yuntech.deu.tw", password: "01A3b7404933") { (user, error) in
                    if (error != nil) {
                        let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "Error", style: .cancel, handler: nil)
                        alert.addAction(defaultAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
        if let user = Auth.auth().currentUser {
            print("\(user.uid) are login!")
            
           loginStatus.text = "\(user.uid) are login!"
        } else {
            print("not login")
        }
        Auth.auth().addStateDidChangeListener{(auth,user) in
            if let user = user{
                self.loginStatus.text = "\(String(describing: user.email))\n顯示名稱：\(String(describing: user.displayName  ?? ""))\n已驗證電子郵件：\(user.isEmailVerified)"
                if user.isEmailVerified==false{
                    user.sendEmailVerification(completion:{ (error ) in
                        if let error = error{
                            print(error.localizedDescription)
                            
                            
                        }else{
                            self.loginStatus.text = "登入狀態：未登入"
                            self.toast(message: "雲端農業送貨系統，請輸入您的信箱帳密登入")
                        }
                        
                        
                    })
                }
                
                
                
                
            }
            
            func receiveToggleAuthUINotification(_ notification:NSNotification){
                if notification.name.rawValue == "ToggleAuthUINotification"{
                    if notification.userInfo != nil{
                        guard let userInfo = notification.userInfo as? [String:String] else {return}
                        
                    }
                }
            }
            
            
        }
        
       
        
        
        
    }
    @IBAction func loginIn(_ sender: Any) {
        if self.account.text != "subendon@yuntech.edu.tw" || self.password.text != "01A3b7404933" {
              
              // 提示用戶是不是忘記輸入 textfield ？
              
              let alertController = UIAlertController(title: "Error", message: "Please enter an correct email and password.", preferredStyle: .alert)
              
              let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
              alertController.addAction(defaultAction)
              
              self.present(alertController, animated: true, completion: nil)
          
          } else {
              
              Auth.auth().signIn(withEmail: self.account.text!, password: self.password.text!) { (user, error) in
                  
                  if error == nil {
                      
                      // 登入成功，打印 ("You have successfully logged in")
                      
                      //Go to the HomeViewController if the login is sucessful
                      let vc = self.storyboard?.instantiateViewController(withIdentifier: "map")
                      self.present(vc!, animated: true, completion: nil)
                      
                  } else {
                      
                      // 提示用戶從 firebase 返回了一個錯誤。
                      let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                      
                      let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                      alertController.addAction(defaultAction)
                      
                      self.present(alertController, animated: true, completion: nil)
                  }
              }
          }
        }
    
    }
    

extension UIViewController{
    func toast(message:String){
        let alert = UIAlertController.init(title: message, message: nil, preferredStyle: .actionSheet)
        present(alert,animated: true)
        {
            DispatchQueue.main.asyncAfter(deadline:DispatchTime.now()+1.5,execute:{
                alert.dismiss(animated:true,completion:nil)
            })
        }
    }
}
