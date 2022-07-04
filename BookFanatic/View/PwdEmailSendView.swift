import Foundation
import UIKit

class PwdEmailSendView: UIViewController {
    
    // VARIABLES
    struct ForgottenPwdData {
        var email: String?
        var code: String?
    }
    var forgottenPwdData : ForgottenPwdData?
    let spinner = SpinnerViewController()
    
    // WIDGETS
    @IBOutlet weak var emailTF: UITextField!
    
    // LYFECYCLE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! PwdResetCodeView
        destination.forgottenPwdData = forgottenPwdData
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
    @IBAction func next(_ sender: Any) {
        
        if (emailTF.text!.isEmpty){
            self.present(Alert.makeAlert(titre: "Warning", message: "Please type your email"), animated: true)
            return
        }
        
        startSpinner()
        
        forgottenPwdData = ForgottenPwdData(email: emailTF.text, code: String(Int.random(in: 100000..<999999)))
        
        UserViewModel.sharedInstance.sendResetCode(email: (forgottenPwdData?.email)!, resetCode: (forgottenPwdData?.code)! ) { success in
            self.stopSpinner()
            if success {
                self.performSegue(withIdentifier: "resetCodeSegue", sender: self.forgottenPwdData)
            } else {
                self.present(Alert.makeAlert(titre: "Error", message: "Email does not exist"), animated: true)
            }
        }
    }
    
}
