struct Book {
    
    internal init(_id: String? = nil, title: String, author: String, price: Double, description: String, category: String, nbPages: String, coverImage: String, filePDF: String) {
        self._id = _id
        self.title = title
        self.author = author
        self.price = price
        self.description = description
        self.category = category
        self.nbPages = nbPages
        self.coverImage = coverImage
        self.filePDF = filePDF
    }
    
    var _id : String?
    var title : String
    var author : String
    var price  : Double
    var description : String
    var category : String
    var nbPages : String
    var coverImage : String
    var filePDF : String
}
