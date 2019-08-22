import SwiftyJSON

struct OperationHeader : Codable {
    public var upv: Version
    public var op: Operation
    public var appID: String
    public var serverData: String?
    public var exts: [Extension]?
    
    
    init(with json: JSON) throws {
        if let op = json["op"].string, let appId = json["appID"].string, let upv = json["upv"].dictionaryObject {
            self.upv = try Version(with: JSON(upv))
            self.exts = json["exts"].arrayObject as? [Extension]
            self.appID =  appId
            self.serverData = json["serverData"].string
            if let opVal = Operation(rawValue: op) {
                self.op = opVal
                return
            }
        }
        throw FidoError.parsingError

    }
    
    init(_ upv: Version, _ op: Operation, _ appID: String){
        self.upv = upv
        self.op = op
        self.appID = appID
    }
    
    init(request: FidoRequest) throws {
        let header = request.header
        self.upv = header.upv
        self.appID = header.appID
        self.serverData = header.serverData
        self.exts = header.exts
        if let op = Operation(rawValue: header.op.rawValue){
            self.op = op
            return
        }
        throw FidoError.parsingError
    }
}
