import Foundation

import PDFKit
import UIKit
import AVFoundation

class BookTTSView: UIViewController {
    
    // VARIABLES
    let avSpeechSynthesizer = AVSpeechSynthesizer()
    let pdfView = PDFView()
    var currentPage = 1
    var totalPages: Int?
    var currentBook: Book?
    var documentContent: [NSAttributedString] = []
    
    // WIDGETS
    @IBOutlet weak var pageTopLabel: UILabel!
    @IBOutlet weak var pageBottomLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    // LYFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        avSpeechSynthesizer.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let pdfDocument = PDFDocument(url: URL(string: currentBook!.filePDF.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
        
        pdfView.document = pdfDocument
        
        let pageCount = pdfDocument!.pageCount
        
        for i in 0 ..< pageCount {
            guard let page = pdfDocument!.page(at: i) else { continue }
            guard let pageContent = page.attributedString else { continue }
            documentContent.append(pageContent)
        }
        
        totalPages = pageCount
        
        playButton.isEnabled = true
        nextButton.isEnabled = true
        
        refreshPage()
    }
    
    // METHODS
    func refreshPage() {
        pageTopLabel.text = "Page " + String(currentPage)
        textView.text = documentContent[currentPage].string
        pageBottomLabel.text = String(currentPage) + "/" + String(totalPages!)
        
        playButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        avSpeechSynthesizer.stopSpeaking(at: .immediate)
    }
    
    // WIDGET ACTIONS
    @IBAction func previous(_ sender: UIButton) {
        currentPage -= 1
        
        nextButton.isEnabled = true
        previousButton.isEnabled = !(currentPage == 1)
        
        refreshPage()
    }
    
    @IBAction func next(_ sender: UIButton) {
        currentPage += 1
        
        nextButton.isEnabled = !(currentPage == totalPages)
        previousButton.isEnabled = true
        
        refreshPage()
    }
    
    @IBAction func playTTS(_ sender: Any) {
        
        if avSpeechSynthesizer.isPaused {
            playButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
            avSpeechSynthesizer.continueSpeaking()
            print("isPaused .. continuing now")
            return
        }
        
        if avSpeechSynthesizer.isSpeaking {
            playButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
            avSpeechSynthesizer.pauseSpeaking(at: .immediate)
            print("isSpeaking .. pausing now")
        } else {
            playButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
            let utterance = AVSpeechUtterance(string: documentContent[currentPage].string)
            avSpeechSynthesizer.speak(utterance)
            print("isNotSpeaking .. playing now")
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        avSpeechSynthesizer.stopSpeaking(at: .immediate)
    }
}

extension BookTTSView: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("Speech finished")
        playButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
    }
}
