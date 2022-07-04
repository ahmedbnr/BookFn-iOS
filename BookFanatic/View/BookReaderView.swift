import Foundation

import PDFKit
import UIKit

class BookReaderView: UIViewController {
    
    // VARIABLES
    let pdfView = PDFView()
    var currentBook: Book?
    
    // WIDGETS
    @IBOutlet weak var backButtonView: UIView!
    
    // LYFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(pdfView)
        view.sendSubviewToBack(pdfView)
        
        pdfView.document = PDFDocument(url: URL(string: currentBook!.filePDF.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pdfView.frame = view.bounds
    }
    
    // METHODS
    
    // WIDGET ACTIONS
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
