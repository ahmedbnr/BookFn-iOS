import Foundation
import UIKit

class PwdEditView: UIViewController {
    
    // VARIABLES
    let spinner = SpinnerViewController()
    
    // WIDGETS
    @IBOutlet weak var currentPasswordTF: UITextField!
    @IBOutlet weak var newPasswordTF: UITextField!
    @IBOutlet weak var newPasswordConfirmationTF: UITextField!
    
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
    @IBAction func changePassword(_ sender: Any) {
        
        if currentPasswordTF.text!.isEmpty {
            self.present(Alert.makeAlert(titre: "Warning", message: "Please type your current password"), animated: true)
            return
        }
        
        if newPasswordTF.text!.isEmpty {
            self.present(Alert.makeAlert(titre: "Warning", message: "Please type your new password"), animated: true)
            return
        }
        
        if newPasswordConfirmationTF.text!.isEmpty {
            self.present(Alert.makeAlert(titre: "Warning", message: "Please type the password confirmation"), animated: true)
            return
        }
        
        if !(newPasswordTF.text! == newPasswordConfirmationTF.text!) {
            self.present(Alert.makeAlert(titre: "Warning", message: "Password and confirmation don't match"), animated: true)
            return
        }
        
        startSpinner()
        
        UserViewModel.sharedInstance.editPassword(currentPassword: currentPasswordTF.text!, newPassword: newPasswordTF.text!, completed: { (statusCode)  in
            self.stopSpinner()
            
            if statusCode == 201 {
                let alert = UIAlertController(title: "Success", message: "Your password has been modified.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                    self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(action)
                self.present(alert, animated: true)
            } else if statusCode == 204{
                self.present(Alert.makeAlert(titre: "Error", message: "Old password is wrong."), animated: true)
            } else {
                self.present(Alert.makeServerErrorAlert(), animated: true)
            }
        })
    }
    
}
