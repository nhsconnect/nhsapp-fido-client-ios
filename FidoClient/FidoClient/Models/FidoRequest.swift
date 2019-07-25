class FidoRequest : Codable {
    var header: OperationHeader
    var challenge: String
 
    init(with json: JSON) throws {
        if let challenge = json["challenge"].string,
            let header = json["header"].dictionaryObject {
            self.header = try OperationHeader(with: JSON(header))
            self.challenge = challenge
            
            return
        }
        throw FidoError.parsingError
    }
}
