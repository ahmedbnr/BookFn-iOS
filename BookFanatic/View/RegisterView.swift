import Foundation
import UIKit

class RegisterView: UIViewController {
    
    // VARIABLES
    let spinner = SpinnerViewController()
    
    // WIDGETS
    @IBOutlet weak var firstnameTF: UITextField!
    @IBOutlet weak var lastnameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var passwordConfirmationTF: UITextField!
    
    // LYFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // METHODS
    func startSpinner() {
        addChild(spinner)
        spinner.view.frame = view.frame
        view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
    }
    
    func stopSpinner() {
        spinner.willMove(toParent: nil)
        spinner.view.removeFromSuperview()
        spinner.removeFromParent()
    }
    
    // WIDGET ACTIONS
    @IBAction func register(_ sender: Any) {
        
        if firstnameTF.text!.isEmpty {
            self.present(Alert.makeAlert(titre: "Warning", message: "Please type your firstname"), animated: true)
            return
        }
        
        if lastnameTF.text!.isEmpty {
            self.present(Alert.makeAlert(titre: "Warning", message: "Please type your lastname"), animated: true)
            return
        }
        
        if emailTF.text!.isEmpty {
            self.present(Alert.makeAlert(titre: "Warning", message: "Please type your email"), animated: true)
            return
        }
        
        if passwordTF.text!.isEmpty {
            self.present(Alert.makeAlert(titre: "Warning", message: "Please type your password"), animated: true)
            return
        }
        
        if passwordConfirmationTF.text!.isEmpty {
            self.present(Alert.makeAlert(titre: "Warning", message: "Please type the password confirmation"), animated: true)
            return
        }
        
        if !(passwordTF.text! == passwordConfirmationTF.text!) {
            self.present(Alert.makeAlert(titre: "Warning", message: "Password and confirmation don't match"), animated: true)
            return
        }
        
        if !(emailTF.text!.contains("@")){
            self.present(Alert.makeAlert(titre: "Warning", message: "Please type your email correctly"), animated: true)
            return
        }
        
        let user = User(firstName: firstnameTF.text!, lastName: lastnameTF.text!, email: emailTF.text!, pwd: passwordTF.text!, img: "")
        
        startSpinner()
        
        UserViewModel.sharedInstance.register(user: user, completed: { (success)  in
            self.stopSpinner()
            
            if success {
                let alert = UIAlertController(title: "Success", message: "Your account has been created.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                    self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(action)
                self.present(alert, animated: true)
            } else {
                self.present(Alert.makeAlert(titre: "Error", message: "Account may already exist."), animated: true)
            }
        })
    }
}
