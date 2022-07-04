import Foundation

import Alamofire

class ImageLoader{
    
    static let shared: ImageLoader = {
        let instance = ImageLoader()
        return instance
    }()
    
    let imageCache = NSCache<NSString,UIImage>()
    let utilityQueue = DispatchQueue.global(qos: .utility)
    
    func loadImage(identifier:String, url:String, completion: @escaping (UIImage?) -> () ) {
        
        print("loading image : " + url)
        
        if let cachedImage = self.imageCache.object(forKey: NSString(string: identifier)) {
            completion(cachedImage)
        }else{
            utilityQueue.async {
                //let url = URL(string: url.stringByAddingPercentEncodingForRFC3986()!)!
                let url = URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
                
                
                guard let data = try? Data(contentsOf: url) else {return}
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.imageCache.setObject(image!, forKey: NSString(string: identifier))
                    completion (image)
                }
            }
        }
    }
}
