import Foundation

import SwiftyJSON
import Alamofire

class UserViewModel {
    
    static let sharedInstance = UserViewModel()
    
    func register(user: User?,  completed: @escaping (Bool) -> Void ) {
        AF.request(BASE_URL + "users",
                   method: .post,
                   parameters: [
                    "firstName": user!.firstName,
                    "lastName": user!.lastName,
                    "email": user!.email,
                    "pwd": user!.pwd,
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
    
    func login(email: String?, password: String?,  completed: @escaping (Bool) -> Void ) {
        AF.request(BASE_URL + "login",
                   method: .post,
                   parameters: [
                    "email": email!,
                    "pwd": password!
                   ],
                   encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { response in
                switch response.result {
                case .success:
                    let user = User(
                        _id: JSON(response.data!)["message"]["_id"].stringValue,
                        firstName: JSON(response.data!)["message"]["firstName"].stringValue,
                        lastName: JSON(response.data!)["message"]["lastName"].stringValue,
                        email: JSON(response.data!)["message"]["email"].stringValue,
                        pwd: JSON(response.data!)["message"]["pwd"].stringValue,
                        img: JSON(response.data!)["message"]["img"].stringValue
                    )
                    do {
                        try UserDefaults.standard.set(JSONEncoder().encode(user), forKey: "user")
                    } catch {
                        print("Unable to encode user (\(error))")
                    }
                    
                    completed(true)
                case let .failure(error):
                    debugPrint(error)
                    completed(false)
                }
            }
    }
    
    func loginWithSocial(firstName: String, lastName: String, email: String, completed: @escaping (Bool) -> Void ) {
        AF.request(BASE_URL + "signupgoogle",
                   method: .post,
                   parameters: [
                    "firstName": firstName,
                    "lastName": lastName,
                    "email": email,
                    "img": ""
                   ],
                   encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { response in
                switch response.result {
                case .success:
                    let user = User(
                        _id: JSON(response.data!)["user"]["_id"].stringValue,
                        firstName: JSON(response.data!)["user"]["firstName"].stringValue,
                        lastName: JSON(response.data!)["user"]["lastName"].stringValue,
                        email: JSON(response.data!)["user"]["email"].stringValue,
                        pwd: JSON(response.data!)["user"]["pwd"].stringValue,
                        img: JSON(response.data!)["user"]["img"].stringValue
                    )
                    do {
                        try UserDefaults.standard.set(JSONEncoder().encode(user), forKey: "user")
                    } catch {
                        print("Unable to encode user (\(error))")
                    }
                    
                    completed(true)
                case let .failure(error):
                    debugPrint(error)
                    completed(false)
                }
            }
    }
    
    func refreshSession(completed: @escaping (Bool) -> Void ) {
        
        var user: User? = nil
        
        if let userData = UserDefaults.standard.data(forKey: "user") {
            do {
                user = try JSONDecoder().decode(User.self, from: userData)
            } catch {
                print("Unable to decode user (\(error))")
            }
        }
        
        print("refreshing user : ")
        print(user!)
        
        if user?._id != nil {
            AF.request(BASE_URL + "getuserbyid",
                       method: .post,
                       parameters: [
                        "id": (user?._id)!
                       ],
                       encoding: JSONEncoding.default)
                .validate(statusCode: 200..<300)
                .validate(contentType: ["application/json"])
                .responseData { response in
                    switch response.result {
                    case .success:
                        let user = User(
                            _id: JSON(response.data!)["dataid"]["_id"].stringValue,
                            firstName: JSON(response.data!)["dataid"]["firstName"].stringValue,
                            lastName: JSON(response.data!)["dataid"]["lastName"].stringValue,
                            email: JSON(response.data!)["dataid"]["email"].stringValue,
                            pwd: JSON(response.data!)["dataid"]["pwd"].stringValue,
                            img: JSON(response.data!)["dataid"]["img"].stringValue
                        )
                        do {
                            try UserDefaults.standard.set(JSONEncoder().encode(user), forKey: "user")
                        } catch {
                            print("Unable to encode user (\(error))")
                        }
                        
                        completed(true)
                    case let .failure(error):
                        debugPrint(error)
                        completed(false)
                    }
                }
        } else {
            completed(false)
        }
    }
    
    func updateProfile(user: User?,  completed: @escaping (Bool) -> Void ) {
        AF.request(BASE_URL + "updateuser",
                   method: .patch,
                   parameters: [
                    "_id": user!._id!,
                    "firstName": user!.firstName,
                    "lastName": user!.lastName,
                    "email": user!.email
                   ],
                   encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { response in
                switch response.result {
                case .success:
                    do {
                        try UserDefaults.standard.set(JSONEncoder().encode(user), forKey: "user")
                    } catch {
                        print("Unable to encode user (\(error))")
                    }
                    completed(true)
                case let .failure(error):
                    debugPrint(error)
                    completed(false)
                }
            }
    }
    
    func updateProfilePicture(email: String, uiImage: UIImage, completed: @escaping (Bool) -> Void ) {
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(uiImage.jpegData(compressionQuality: 0.5)!, withName: "img" , fileName: "image.jpeg", mimeType: "image/jpeg")
            
            for (key, value) in
                    [
                        "email": email,
                    ]
            {
                multipartFormData.append((value.data(using: .utf8))!, withName: key)
            }
            
        },to: BASE_URL + "edit-profile-picture",
                  method: .put)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { response in
                switch response.result {
                case .success:
                    print("Success")
                    completed(true)
                case let .failure(error):
                    completed(false)
                    print(error)
                }
            }
    }
    
    func editPassword(currentPassword: String?, newPassword: String?,  completed: @escaping (Int) -> Void ) {
        var user: User? = nil
        if let userData = UserDefaults.standard.data(forKey: "user") {
            do {
                user = try JSONDecoder().decode(User.self, from: userData)
            } catch {
                print("Unable to decode user (\(error))")
            }
        }
        
        AF.request(BASE_URL + "change-password",
                   method: .post,
                   parameters: [
                    "email": user!.email,
                    "oldPassword": currentPassword!,
                    "newPassword": newPassword!
                   ],
                   encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { response in
                switch response.result {
                case .success:
                    completed(response.response!.statusCode)
                case let .failure(error):
                    debugPrint(error)
                    completed(500)
                }
            }
    }
    
    func sendResetCode(email: String, resetCode: String, completed: @escaping (Bool) -> Void ) {
        AF.request(BASE_URL + "forgot-password",
                   method: .post,
                   parameters: [
                    "email": email,
                    "codeDeReinit": resetCode
                   ],
                   encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { response in
                switch response.result {
                case .success:
                    print("Validation Successful")
                    completed(true)
                case let .failure(error):
                    debugPrint(error)
                    completed(false)
                }
            }
    }
    
    func resetPassword(email: String, newPassword: String?, completed: @escaping (Bool) -> Void ) {
        AF.request(BASE_URL + "reset-password",
                   method: .post,
                   parameters: [
                    "email": email,
                    "newPassword": newPassword!
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
    
    func deleteAccount(completed: @escaping (Bool) -> Void ) {
        
        var user: User? = nil
        
        if let userData = UserDefaults.standard.data(forKey: "user") {
            do {
                user = try JSONDecoder().decode(User.self, from: userData)
            } catch {
                print("Unable to decode user (\(error))")
            }
        }
        
        AF.request(BASE_URL + "one/" + (user?._id)!,
                   method: .delete,
                   encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { response in
                switch response.result {
                case .success:
                    UserDefaults.standard.set(nil, forKey: "user")
                    completed(true)
                case let .failure(error):
                    debugPrint(error)
                    completed(false)
                }
            }
    }
}
