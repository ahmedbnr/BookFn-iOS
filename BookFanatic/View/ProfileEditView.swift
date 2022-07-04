import Foundation
import UIKit

class ProfileEditView: UIViewController {
    
    // VARIABLES
    let spinner = SpinnerViewController()
    var currentUser: User? = nil
    
    // WIDGETS
    @IBOutlet weak var firstnameTF: UITextField!
    @IBOutlet weak var lastnameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    
    // LYFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userData = UserDefaults.standard.data(forKey: "user") {
            do {
                currentUser = try JSONDecoder().decode(User.self, from: userData)
            } catch {
                print("Unable to decode user (\(error))")
            }
        }
        
        firstnameTF.text! = currentUser!.firstName
        lastnameTF.text! = currentUser!.lastName
        emailTF.text! = currentUser!.email
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
    @IBAction func updateProfile(_ sender: Any) {
        
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
        
        if !(emailTF.text!.contains("@")){
            self.present(Alert.makeAlert(titre: "Warning", message: "Please type your email correctly"), animated: true)
            return
        }
        
        currentUser?.firstName = firstnameTF.text!
        currentUser?.lastName = lastnameTF.text!
        currentUser?.email = emailTF.text!
        
        startSpinner()
        
        UserViewModel.sharedInstance.updateProfile(user: currentUser, completed: { (success)  in
            self.stopSpinner()
            
            if success {
                let alert = UIAlertController(title: "Success", message: "Your profile has been edited.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                    ModalTransitionMediator.instance.sendPopoverDismissed(modelChanged: true)
                    self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(action)
                self.present(alert, animated: true)
            } else {
                self.present(Alert.makeAlert(titre: "Error", message: "Couldn't edit profile."), animated: true)
            }
        })
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        let action = UIAlertAction(title: "Yes", style: .destructive) { act in
            UserViewModel.sharedInstance.deleteAccount( completed: { (success)  in
                self.stopSpinner()
                
                if success {
                    let alert = UIAlertController(title: "Success", message: "Your profile has been edited.", preferredStyle: .alert)
                    let secondaryAction = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                        self.performSegue(withIdentifier: "logoutSegue", sender: nil)
                    }
                    alert.addAction(secondaryAction)
                    self.present(alert, animated: true)
                } else {
                    self.present(Alert.makeAlert(titre: "Error", message: "Internal server error"), animated: true)
                }
            })
        }
        self.present(Alert.makeActionAlert(titre: "Confirmation", message: "Are you sure you want to delete your account", action: action), animated: true)
    }
    
}
