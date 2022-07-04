import Foundation
import UIKit

class PwdResetCodeView: UIViewController {
    
    // VARIABLES
    var forgottenPwdData : PwdEmailSendView.ForgottenPwdData?
    
    // WIDGETS
    @IBOutlet weak var resetCodeTF: UITextField!
    
    // LYFECYCLE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! PwdResetView
        destination.email = forgottenPwdData?.email
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // METHODS
    
    // WIDGET ACTIONS
    @IBAction func next(_ sender: Any) {
        
        if (resetCodeTF.text!.isEmpty){
            self.present(Alert.makeAlert(titre: "Warning", message: "Please type the code"), animated: true)
            return
        }
        
        if (resetCodeTF.text == forgottenPwdData?.code ) {
            self.performSegue(withIdentifier: "changePasswordSegue", sender: forgottenPwdData?.email)
        } else {
            self.present(Alert.makeAlert(titre: "Error", message: "Code incorrect"), animated: true)
        }
    }
    
}
