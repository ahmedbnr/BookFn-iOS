import Foundation
import UIKit

class BookDetailsView: UIViewController {
    
    // VARIABLES
    var currentBook: Book?
    var user: User? = nil
    
    // WIDGETS
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var pagesLabel: UILabel!
    @IBOutlet weak var descriptionTV: UITextView!
    @IBOutlet weak var centerImageView: UIImageView!
    @IBOutlet weak var backImageView: UIImageView!
    
    // LYFECYCLE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "readSegue"){
            let destination = segue.destination as? BookReaderView
            destination?.currentBook = currentBook
        } else if (segue.identifier == "playSegue") {
            let destination = segue.destination as? BookTTSView
            destination?.currentBook = currentBook
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        SecondaryModalTransitionMediator.instance.sendPopoverDismissed(modelChanged: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userData = UserDefaults.standard.data(forKey: "user") {
            do {
                user = try JSONDecoder().decode(User.self, from: userData)
            } catch {
                print("Unable to decode user (\(error))")
            }
        }
        
        
        titleLabel.text = currentBook!.title
        authorLabel.text = currentBook!.author
        pagesLabel.text = currentBook!.nbPages
        descriptionTV.text = currentBook!.description
        
        ImageLoader.shared.loadImage(
            identifier: currentBook!.coverImage,
            url: IMAGE_URL + currentBook!.coverImage,
            completion: { [self] image in
                backImageView.image = image
                centerImageView.image = image
            }
        )
        
    }
    
    // METHODS
    
    // WIDGET ACTIONS
    @IBAction func readBook(_ sender: Any) {
        BookViewModel.sharedInstance.addLikesBook(bookid: (currentBook?._id)!, userid: (user?._id)!) { success in}
        self.performSegue(withIdentifier: "readSegue", sender: currentBook)
    }
    
    @IBAction func playBook(_ sender: Any) {
        BookViewModel.sharedInstance.addLikesBook(bookid: (currentBook?._id)!, userid: (user?._id)!) { success in}
        self.performSegue(withIdentifier: "playSegue", sender: currentBook)
    }
    
}
