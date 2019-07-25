struct ChannelBinding: Codable {
    var serverEndpoint: String?
    var tlsServerCertificate: String?
    var tlsUnique: String?
    var cidPubKey: String?
    
    
    init(serverEndpoint: String? = nil, tlsServerCertificate: String? = nil, tlsUnique: String? = nil, cidPubKey: String? = nil){
        self.serverEndpoint = serverEndpoint
        self.tlsServerCertificate = tlsServerCertificate
        self.tlsUnique = tlsUnique
        self.cidPubKey = cidPubKey
    }
    
}
