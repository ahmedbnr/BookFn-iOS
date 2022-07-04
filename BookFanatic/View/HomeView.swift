import Foundation
import UIKit

class HomeView: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, SecondaryModalTransitionListener  {

    // VARIABLES
    var currentUser: User? = nil
    var selectedBook: Book?
    var readBooks: [Book] = []
    var books: [Book] = []
    
    // WIDGETS
    @IBOutlet weak var readBooksCV: UICollectionView!
    @IBOutlet weak var booksTV: UITableView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var firstBookTitleLabel: UILabel!
    @IBOutlet weak var firstBookAuthorLabel: UILabel!
    @IBOutlet weak var firstBookCover: UIImageView!
    
    @IBOutlet weak var continueButtonView: UIView!
    @IBOutlet weak var playButtonView: UIView!
    
    // LYFECYCLE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bookDetailsSegue" {
            let destination = segue.destination as! BookDetailsView
            destination.currentBook = selectedBook!
        } else if (segue.identifier == "readSegue"){
            let destination = segue.destination as? BookReaderView
            destination?.currentBook = selectedBook!
        } else if (segue.identifier == "playSegue") {
            let destination = segue.destination as? BookTTSView
            destination?.currentBook = selectedBook!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SecondaryModalTransitionMediator.instance.setListener(listener: self)
        
        if let userData = UserDefaults.standard.data(forKey: "user") {
            do {
                currentUser = try JSONDecoder().decode(User.self, from: userData)
            } catch {
                print("Unable to decode user (\(error))")
            }
        }
    }
    
    func popoverDismissed() {
        print("hi")
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadData()
    }
    
    // PROTOCOLS
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        readBooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let contentView = cell.contentView
        
        let coverImage = contentView.viewWithTag(1) as! UIImageView
        coverImage.layer.cornerRadius = CGFloat(ROUNDED_RADIUS)
        
        let book = readBooks[indexPath.row]
        
        ImageLoader.shared.loadImage(
            identifier: book.coverImage,
            url: IMAGE_URL + book.coverImage,
            completion: { [] image in
                coverImage.image = image
            }
        )
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedBook = readBooks[indexPath.row]
        performSegue(withIdentifier: "bookDetailsSegue", sender: selectedBook)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let contentView = cell.contentView
        
        let coverImage = contentView.viewWithTag(1) as! UIImageView
        coverImage.layer.cornerRadius = CGFloat(ROUNDED_RADIUS)
        let titleLabel = contentView.viewWithTag(2) as! UILabel
        let descriptionLabel = contentView.viewWithTag(3) as! UILabel
        let categoryButton = contentView.viewWithTag(4) as! UIButton
        
        let book = books[indexPath.row]
        
        titleLabel.text = book.title
        descriptionLabel.text = book.author
        categoryButton.layer.cornerRadius = CGFloat(10)
        categoryButton.setTitle(book.category, for: .normal)
        
        ImageLoader.shared.loadImage(
            identifier: book.coverImage,
            url: IMAGE_URL + book.coverImage,
            completion: { [] image in
                coverImage.image = image
            }
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBook = books[indexPath.row]
        performSegue(withIdentifier: "bookDetailsSegue", sender: selectedBook)
    }
    
    // METHODS
    func loadData() {
        BookViewModel.sharedInstance.getAll{ [self]success, booksFromServer in
            if success {
                
                initialize()
                
                books = booksFromServer!.shuffled()
                readBooks = books.shuffled()
                
                booksTV.reloadData()
            }else {
                present(Alert.makeAlert(titre: "Error", message: "Could not load books"), animated: true)
            }
        }
        
        BookViewModel.sharedInstance.listRecentlyRead(userid: (currentUser?._id)!) { [self]success, booksFromServer in
            if success {
                selectedBook = booksFromServer?.last
                readBooks = booksFromServer!
                readBooksCV.reloadData()
            } else {
                present(Alert.makeAlert(titre: "Error", message: "Could not load books"), animated: true)
            }
        }
    }
    
    func initialize() {
        BookViewModel.sharedInstance.showLastReadBook(userid: (currentUser?._id)!) { [self] success, hasBook, book in
            if success {
                if hasBook {
                    firstBookTitleLabel.text = book?.title
                    firstBookAuthorLabel.text = "By " + book!.author
                    firstBookCover.layer.cornerRadius = CGFloat(ROUNDED_RADIUS)
                    continueButtonView.isHidden = false
                    playButtonView.isHidden = false
                    
                    ImageLoader.shared.loadImage(
                        identifier: book!.coverImage,
                        url: IMAGE_URL + book!.coverImage,
                        completion: { [self] image in
                            firstBookCover.image = image
                        }
                    )
                } else {
                    firstBookTitleLabel.text = "Sadly, you haven't read any book yet!"
                    firstBookAuthorLabel.text = "Try reading some"
                    firstBookCover.layer.cornerRadius = CGFloat(ROUNDED_RADIUS)
                    continueButtonView.isHidden = true
                    playButtonView.isHidden = true
                    
                   
                }
            }
        }
        
        userLabel.text = "Hi " + currentUser!.firstName + " !"
    }
    
    // WIDGET ACTIONS
    @IBAction func readBook(_ sender: Any) {
        self.performSegue(withIdentifier: "readSegue", sender: selectedBook)
    }
    
    @IBAction func playBook(_ sender: Any) {
        self.performSegue(withIdentifier: "playSegue", sender: selectedBook)
    }
}
