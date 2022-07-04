import Foundation
import UIKit

extension UIImageView {
    
    func roundedGrayPhoto() {
        self.backgroundColor = UIColor.gray
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.size.width/2
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 5.0
    }
}
