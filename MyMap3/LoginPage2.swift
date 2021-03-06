import UIKit
import FirebaseAuth
import Firebase
import FirebaseCore
class LoginPage2: UIViewController, UITextFieldDelegate {

    var mAuth:Auth!
    @IBOutlet weak var account: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var resultLbl: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var countingLbl: UILabel!
    @IBOutlet weak var loginStatus:UILabel!
    
    
    var checkMsg:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        mAuth = Auth.auth()
        Auth.auth().createUser(withEmail: "peter@neverland.com", password: "123456") { result, error in
                    
             guard let user = result?.user,
                   error == nil else {
                 print(error?.localizedDescription)
                 return
             }
             print(user.email, user.uid)
        }
        Auth.auth().signIn(withEmail: "peter@neverlad.com", password: "123456") { result, error in
             guard error == nil else {
                print(error?.localizedDescription)
                return
             }
            
        }
        if let user = Auth.auth().currentUser {
            print("\(user.uid) login")
            print("success")
        } else {
            print("not login")
        }
    }
 
    @objc func countPassword(_ sender: UITextField) {
        if let passwordCounting = password.text?.count{
        if passwordCounting != 0{
            countingLbl.text = String(passwordCounting)
            }
            else {
                countingLbl.text = ""
            }
        }
        guard password.isEditing == true else{
            countingLbl.isHidden = true
            password.isSecureTextEntry = true
            return
        }
        countingLbl.isHidden = false
        password.isSecureTextEntry = false
    }
    
    
    @objc func check() {
        let usernameTxt = account.text ?? ""
        let password = password.text ?? ""
        
        guard usernameTxt != "" else{
            resultLbl.text = inputStatus.usernameisEmpty.alert
            return
        }
        guard password != "" else{
            resultLbl.text = inputStatus.passwordisEmpty.alert
            return
        }

        checkMsg = []
        for i in warning.allCases{
        checkMsg.append(i.rawValue)
        }

        //????????????
        if password.count >= 16{
            removeWarning(warning.count.rawValue)
        }
        
        //????????????
        for digit in passwordPolicy.digits{
            if password.contains(digit) == true{
                removeWarning(warning.digit.rawValue)
                break
            }
        }

        //??????????????????
        for i in passwordPolicy.punctuation{
            if password.contains(i) == true{
                removeWarning(warning.punctuation.rawValue)
                break
            }
        }
        
        //?????????????????????
        if password.contains(usernameTxt) == false{
            removeWarning(warning.username.rawValue)
        }
        
        //????????????
        for character in password{
            if character.isUppercase == true{
                removeWarning(warning.uppercase.rawValue)
            }
        }
        
        //????????????
        for character in password{
            if character.isLowercase == true{
                removeWarning(warning.lowercase.rawValue)
            }
        }
                  
        let checkResult = checkMsg.map {$0}.joined(separator: "\n")
        resultLbl.text = checkResult

        guard usernameTxt != "", checkMsg == [] else{
            sendBtn.isEnabled = false
            return
        }
        sendBtn.isEnabled = true
        if(account.isEqual("sme322")){
            if(password.isEqual("~@Xiemengy7~@@@@")){
                print("????????????")
            }
            
            
        }
        }
    
    func removeWarning(_ warningString: String){
        checkMsg.removeAll { (removeMessage) -> Bool in
            let removeMessage = removeMessage == warningString
            return removeMessage
    }
}
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.contains(" ") == true{
            return false
        }else{
            return true
        }
    }
    
    @IBAction func closeKeyboard(_ sender: Any) {
    }
    
    
    @IBSegueAction func nextPage(_ coder: NSCoder) -> infoConfirmVC? {
        let infoConfirmViewController = infoConfirmVC(coder: coder)
        let usernameTxt = account.text ?? ""
        let password = password.text ?? ""
        infoConfirmViewController?.confirmUsername = usernameTxt
        infoConfirmViewController?.confirmPassword = password
        return infoConfirmViewController
    }
    
    @IBAction func unwindSegueBack(segue: UIStoryboardSegue){
    }
}
class passwordPolicy{
    
    static let digits = "0123456789"
    static let punctuation = "!@#$%^&*(),.<>;'`~[]{}\\|/?_-+="

}


enum warning:String, CaseIterable{
    
    case count = "?????????????????????16?????????"
    case digit = "?????????????????????????????????"
    case punctuation = "???????????????????????????????????????"
    case lowercase = "???????????????????????????????????????"
    case uppercase = "???????????????????????????????????????"
    case username = "?????????????????????????????????"

}

enum inputStatus{
    case usernameisEmpty
    case passwordisEmpty
 
    var alert: String{
        switch self {
        case .usernameisEmpty:
            return "????????????????????????"
        case .passwordisEmpty:
            return "???????????????"
            
        }
    }
}
extension UIColor{
    
    class func hexToRGB(hex:String) -> UIColor{
        let nInt = Int(hex, radix: 16)
        let rColor = (nInt! >> 16) & 0xFF
        let gColor = (nInt! >> 8) & 0xFF
        let bColor = nInt! & 0xFF
        
        return UIColor(red: CGFloat(rColor) / 255, green: CGFloat(gColor) / 255, blue: CGFloat(bColor) / 255, alpha: 1)
        
    }

}
class infoConfirmVC: UIViewController {
    
   
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var passwordLbl: UILabel!
    
    var confirmUsername = ""
    var confirmPassword = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameLbl.text = confirmUsername
        passwordLbl.text = confirmPassword
    }
}

