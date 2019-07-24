struct DeregisterAuthenticator : Codable {
    public var aaid: String?
    public var keyID: String
    
    init(aaid: String?, keyID: String){
        self.aaid = aaid
        self.keyID = keyID
    }
}
