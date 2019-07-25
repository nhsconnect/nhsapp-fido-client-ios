struct DeregistrationRequest : Codable {
    var header: OperationHeader
    var authenticators: [DeregisterAuthenticator]
}
