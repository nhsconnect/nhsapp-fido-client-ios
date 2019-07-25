struct Assertion: Codable {
    var assertionScheme: String? = nil
    var assertion: String? = nil
    var tcDisplayPNGCharacteristics: [DisplayPNGCharacteristicsDescriptor]? = nil
    var exts: [Extension]? = nil
    
    
    init(assertionScheme: String? = nil, assertion: String? = nil, tcDisplayPNGCharacteristics: [DisplayPNGCharacteristicsDescriptor]? = nil, exts: [Extension]? = nil){
        self.assertionScheme = assertionScheme
        self.assertion = assertion
        self.tcDisplayPNGCharacteristics = tcDisplayPNGCharacteristics
        self.exts = exts
    }
}
