import Foundation
import UIKit

class CheckSessionView: UIViewController {
    
    // LYFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadUser();
    }
    
    func loadUser() {
        if let userData = UserDefaults.standard.data(forKey: "user") {
            do {
                let user = try JSONDecoder().decode(User.self, from: userData)
                print(user)
            } catch {
                self.performSegue(withIdentifier: "loginPageSegue", sender: nil)
                print("Unable to decode user (\(error))")
            }
            
            refreshSessionAndGo()
        } else {
            self.performSegue(withIdentifier: "loginPageSegue", sender: nil)
        }
    }
    
    func refreshSessionAndGo() {
        UserViewModel.sharedInstance.refreshSession { [self] success in
            if success {
                self.performSegue(withIdentifier: "homeSegue", sender: nil)
            } else {
                let firstAction = UIAlertAction(title: "Retry", style: .default) { UIAlertAction in
                    refreshSessionAndGo()
                }
                let secondAction = UIAlertAction(title: "Abort", style: .destructive) { UIAlertAction in
                    UserDefaults.standard.set(nil, forKey: "user")
                    loadUser()
                }
                self.present(Alert.makeDoubleActionAlert(titre: "Error", message: "Could not resume session", firstAction: firstAction, secondAction: secondAction), animated: true)
            }
        }
    }
}
