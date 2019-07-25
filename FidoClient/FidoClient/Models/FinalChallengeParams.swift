struct FinalChallengeParams: Codable {
    var appID: String?
    var challenge: String?
    var facetID: String?
    var channelBindings: ChannelBinding?
    
    init(appId: String? = nil, challenge: String? = nil, facetId: String? = nil, channelBindings: ChannelBinding? = nil) {
        self.appID = appId
        self.challenge = challenge
        self.facetID = facetId
        self.channelBindings = channelBindings
    }
}
