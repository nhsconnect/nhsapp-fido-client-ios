struct Version : Codable{
    public let major: Int
    public let minor: Int
    
    init(with json: JSON) throws {
        if let major = json["major"].int, let minor = json["minor"].int {
            self.major = major
            self.minor = minor
            return
        }
        
        throw FidoError.parsingError
    }
    
    init(major: Int, minor: Int){
        self.minor = minor
        self.major = major
    }
}
