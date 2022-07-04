import Foundation

import SwiftyJSON
import Alamofire

class BookViewModel {
    
    static let sharedInstance = BookViewModel()
    
    func getAll(completed: @escaping (Bool, [Book]?) -> Void ) {
        AF.request(BASE_URL + "allBooks",
                   method: .get, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { response in
                switch response.result {
                case .success:
                    var books : [Book]? = []
                    for singleJsonItem in JSON(response.data!)["response"] {
                        books!.append(self.makeBook(jsonItem: singleJsonItem.1))
                    }
                    completed(true, books)
                case let .failure(error):
                    debugPrint(error)
                    completed(false, nil)
                }
            }
    }
    
    func addLikesBook(bookid: String, userid: String, completed: @escaping (Bool) -> Void ) {
        AF.request(BASE_URL + "addLikesBook",
                   method: .post,
                   parameters: [
                    "bookid": bookid,
                    "userid": userid
                   ],
                   encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { response in
                switch response.result {
                case .success:
                    completed(true)
                case let .failure(error):
                    debugPrint(error)
                    completed(false)
                }
            }
    }
    
    func listRecentlyRead(userid: String, completed: @escaping (Bool, [Book]?) -> Void ) {
        AF.request(BASE_URL + "listRecentlyRead",
                   method: .post,
                   parameters: [
                    "userid": userid
                   ],
                   encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { response in
                switch response.result {
                case .success:
                    var books : [Book]? = []
                    var booksIds : [String] = []
                    
                    for singleJsonItem in JSON(response.data!)["listBooks"] {
                        let book = self.makeBook(jsonItem: singleJsonItem.1);
                        
                        if !(booksIds.contains(book._id!)){
                            books!.append(book)
                            booksIds.append(book._id!)
                        }
                    }
                    completed(true, books)
                case let .failure(error):
                    debugPrint(error)
                    completed(false, nil);
                }
            }
    }
    
    func showLastReadBook(userid: String, completed: @escaping (Bool, Bool, Book?) -> Void ) {
        AF.request(BASE_URL + "lastRecentlyRead",
                   method: .post,
                   parameters: [
                    "userid": userid
                   ],
                   encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { response in
                switch response.result {
                case .success:
                    print(JSON(response.data!))
                    if (JSON(response.data!)["message"] == "an error Occured!"){
                        completed(true, false, nil)
                    } else {
                        let book = self.makeBook(jsonItem: JSON(response.data!)["lastBook"]);
                        completed(true, true, book)
                    }
                case let .failure(error):
                    debugPrint(error)
                    completed(false, false, nil);
                }
            }
    }
    
    func makeBook(jsonItem: JSON) -> Book {
        Book(
            _id: jsonItem["_id"].stringValue,
            title: jsonItem["title"].stringValue,
            author: jsonItem["author"].stringValue,
            price: jsonItem["price"].doubleValue,
            description: jsonItem["description"].stringValue,
            category: jsonItem["category"].stringValue,
            nbPages: jsonItem["nbPages"].stringValue,
            coverImage: jsonItem["coverImage"].stringValue,
            filePDF: jsonItem["filePDF"].stringValue
        )
    }
}
