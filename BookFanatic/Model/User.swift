struct User : Codable {

    internal init(_id: String? = nil, firstName: String, lastName: String, email: String, pwd: String, img: String) {
        self._id = _id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.pwd = pwd
        self.img = img
    }
    
    var _id : String?
    var firstName : String
    var lastName : String
    var email  : String
    var pwd : String
    var img : String
}
