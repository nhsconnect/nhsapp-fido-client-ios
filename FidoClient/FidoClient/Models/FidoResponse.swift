public struct FidoResponse: Codable{
    var header: OperationHeader?
    var fcParams: String
    var assertions: [Assertion]?
    
    init() {
        header = nil
        fcParams = ""
        assertions = []
    }
    
    init(header: OperationHeader, fcParams: String, assertions: [Assertion]){
        self.header = header
        self.fcParams = fcParams
        self.assertions = assertions
    }
}
