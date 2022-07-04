import Foundation
import UIKit

class BookShelfView: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // VARIABLES
    var selectedBook: Book?
    var books: [Book] = []
    
    // WIDGETS
    @IBOutlet weak var booksCV: UICollectionView!
    
    // LYFECYCLE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bookDetailsSegue" {
            let destination = segue.destination as! BookDetailsView
            destination.currentBook = selectedBook!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    // PROTOCOLS
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let contentView = cell.contentView
        
        let coverImage = contentView.viewWithTag(1) as! UIImageView
            coverImage.layer.cornerRadius = CGFloat(ROUNDED_RADIUS)
        
        let book = books[indexPath.row]
        
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
        selectedBook = books[indexPath.row]
        performSegue(withIdentifier: "bookDetailsSegue", sender: selectedBook)
    }
    
    // METHODS
    func loadData() {
        BookViewModel.sharedInstance.getAll{success, booksFromServer in
            if success {
                self.books = booksFromServer!
                self.booksCV.reloadData()
            } else {
                self.present(Alert.makeAlert(titre: "Error", message: "Could not load books"),animated: true)
            }
        }
    }
    
    // WIDGET ACTIONS

}
