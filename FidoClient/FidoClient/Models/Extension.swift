struct Extension : Codable{
    public let id: String
    public let data: String
    public let fail_if_unknown: Bool
    
    init(id: String, data: String, fail_if_unknown: Bool){
        self.id = id
        self.data = data
        self.fail_if_unknown = fail_if_unknown
    }
}
