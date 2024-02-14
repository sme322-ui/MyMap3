//
//  CreateAccountViewController.swift
//  MyMap4
//
//  Created by Mongyan on 2023/5/20.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Firebase
class CreateAccountViewController:UIViewController{
    @IBOutlet weak var newAccount: UITextField!
    
    @IBOutlet weak var newPasswordC: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    
    @IBOutlet weak var displayName: UITextField!
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    @IBAction func createAccount(_ sender:Any){
        let account = newAccount.text ?? ""
        let password = newPassword.text ?? ""
        let passwordC = newPasswordC.text ?? ""
        if account == ""{toast(message: "請輸入帳號");return}
        if password == "" {toast(message: "請輸入密碼");return}
        if password != passwordC{toast(message: "兩次密碼不一致，請確認密碼");return}
        
        Auth.auth().createUser(withEmail: account, password: password){ (user,error) in
            guard let user = user?.user else {
                  if let error = error {
                     debugPrint("Error creating user: \(error.localizedDescription)")
                  } else {
                     debugPrint("Error creating user: unknown error")
                  }
                  return
               }
            if error == nil{
                    let request = user.createProfileChangeRequest()
                    request.displayName = self.displayName.text
                    request.commitChanges(completion:{(error) in
                        print(error!.localizedDescription)
                    })
                 
                }else{
                    self.toast(message: error!.localizedDescription)
        }
        }
        }
        
    }

