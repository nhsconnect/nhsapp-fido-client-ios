class RegistrationRequest : FidoRequest {
    var username: String
    
    override init(with json: JSON) throws {
        
        if let username = json["username"].string {
            self.username = username
            
            do {
                try super.init(with: json)
            } catch FidoError.parsingError {
                throw FidoError.parsingError
            }
            
            return
        }
        
        throw FidoError.parsingError
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
