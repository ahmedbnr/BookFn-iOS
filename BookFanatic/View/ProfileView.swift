import Foundation
import UIKit

class ProfileView: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ModalTransitionListener {
    
    // VARIABLES
    var currentUser: User? = nil
    var currentPhoto : UIImage?
    
    // WIDGETS
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    // LYFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ModalTransitionMediator.instance.setListener(listener: self)
        
        profileImage.roundedGrayPhoto()
        initialize()
    }
    
    // PROTOCOLS
    func popoverDismissed() {
        initialize()
    }
    
    // METHODS
    func initialize() {
        if let userData = UserDefaults.standard.data(forKey: "user") {
            do {
                currentUser = try JSONDecoder().decode(User.self, from: userData)
            } catch {
                print("Unable to decode user (\(error))")
            }
        }
        
        fullnameLabel.text = currentUser!.firstName + " " + currentUser!.lastName
        if (currentUser?.img != ""){
            UserViewModel.sharedInstance.refreshSession { [self] success in
                if success {
                    ImageLoader.shared.loadImage(identifier: (currentUser?.img)!, url: USER_IMAGE_URL + (currentUser?.img)!) { [self] imageResp in
                        profileImage.image = imageResp
                    }
                }else{
                    self.present(Alert.makeServerErrorAlert(), animated: true)
                }
            }
        } else {
            print("Profile picture doesen't exist")
        }
    }
    
    func gallery()
    {
        let myPickerControllerGallery = UIImagePickerController()
        myPickerControllerGallery.delegate = self
        myPickerControllerGallery.sourceType = UIImagePickerController.SourceType.photoLibrary
        myPickerControllerGallery.allowsEditing = true
        self.present(myPickerControllerGallery, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.originalImage] as? UIImage else {
            return
        }
        
        currentPhoto = selectedImage
        
        UserViewModel.sharedInstance.updateProfilePicture(email: currentUser!.email, uiImage: selectedImage, completed: { [self] success in
            if success {
                profileImage.image = selectedImage
                self.present(Alert.makeAlert(titre: "Succes", message: "Photo modifié avec succés"),animated: true)
            } else {
                self.present(Alert.makeServerErrorAlert(),animated: true)
            }
        })
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func showActionSheet(){
        
        let actionSheetController: UIAlertController = UIAlertController(title: NSLocalizedString("Upload Image", comment: ""), message: nil, preferredStyle: .actionSheet)
        actionSheetController.view.tintColor = UIColor.black
        let cancelActionButton: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        
        let deleteActionButton: UIAlertAction = UIAlertAction(title: NSLocalizedString("Choose From Gallery", comment: ""), style: .default)
        { action -> Void in
            self.gallery()
        }
        
        actionSheetController.addAction(deleteActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    // WIDGET ACTIONS
    @IBAction func changePhoto(_ sender: Any) {
        showActionSheet()
    }
    
    @IBAction func logout(_ sender: Any) {
        UserDefaults.standard.set(nil, forKey: "user")
        self.performSegue(withIdentifier: "logoutSegue", sender: nil)
    }
}
