import Foundation
import UIKit
import GoogleSignIn

class LoginView: UIViewController {
    
    // VARIABLES
    let signInConfig = GIDConfiguration.init(clientID: "392871951397-1vmagjv7i7ha1os60ffohj6u8apcvnrt.apps.googleusercontent.com")
    let googleLoginButton = GIDSignInButton()
    let spinner = SpinnerViewController()
    
    // WIDGETS
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var googleLoginView: UIView!
    
    // LYFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        googleLoginView.addSubview(googleLoginButton)
        googleLoginButton.addTarget(self, action: #selector(googleSignIn), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        googleLoginButton.frame = CGRect(x: googleLoginView.center.x - (googleLoginView.frame.width/2) , y: 0, width: googleLoginView.center.x, height: googleLoginView.frame.height)
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
    
    @objc func googleSignIn() {
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { [self] user, error in
            guard error == nil else { return }
            guard let user = user else { return }
            
            if user.profile != nil && user.profile?.givenName != nil && user.profile?.familyName != nil {
                loginWithSocialMedia(firstName: user.profile!.givenName!, lastName: user.profile!.familyName!, email: user.profile!.email, socialMediaName: "Google")
            }
        }
    }
    
    func loginWithSocialMedia(firstName: String, lastName: String, email: String, socialMediaName: String) {
        self.startSpinner()
        UserViewModel.sharedInstance.loginWithSocial(firstName: firstName, lastName: lastName ,email: email, completed: { success in
            if success {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                self.present(Alert.makeAlert(titre: "Error", message: "Could not login with " + socialMediaName), animated: true)
            }
            self.stopSpinner()
        })
    }
    
    // WIDGET ACTIONS
    @IBAction func login(_ sender: Any) {
        
        if(emailTF.text!.isEmpty || passwordTF.text!.isEmpty){
            self.present(Alert.makeAlert(titre: "Warning", message: "Please type your credentials"), animated: true)
            return
        }
        
        startSpinner()
        
        UserViewModel.sharedInstance.login(email: emailTF.text!, password: passwordTF.text!,completed: { (success) in
            self.stopSpinner()
            if success {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                self.present(Alert.makeAlert(titre: "Warning", message: "Email or password incorrect"), animated: true)
            }
        })
    }
}
