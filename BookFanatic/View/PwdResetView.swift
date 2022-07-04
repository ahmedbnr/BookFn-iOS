import Foundation
import UIKit

class PwdResetView: UIViewController {
    
    // VARIABLES
    var email: String?
    let spinner = SpinnerViewController()
    
    // WIDGETS
    @IBOutlet weak var newPasswordTF: UITextField!
    @IBOutlet weak var newPasswordConfirmationTF: UITextField!
    
    // LYFECYCLE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        _ = segue.destination as! LoginView
    }
    
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
    @IBAction func confirmer(_ sender: Any) {
        
        if newPasswordTF.text!.isEmpty {
            self.present(Alert.makeAlert(titre: "Warning", message: "Please type your password"), animated: true)
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
        
        UserViewModel.sharedInstance.resetPassword(email: email!, newPassword: newPasswordTF.text! , completed: { success in
            self.stopSpinner()
            if success {
                let action = UIAlertAction(title: "Back to login", style: .default) { UIAlertAction in
                    self.performSegue(withIdentifier: "backToLoginSegue", sender: nil)
                }
                self.present(Alert.makeSingleActionAlert(titre: "Success", message: "Your password has been changed", action: action), animated: true)
            }else{
                self.present(Alert.makeAlert(titre: "Error", message: "Could not change your password"), animated: true)
            }
        })
    }
}
