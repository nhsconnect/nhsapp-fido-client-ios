import Foundation

struct KeyPair {
    var pubKey: SecKey
    var privKey: SecKey
    
    init(pubKey: SecKey, privKey: SecKey) {
        self.pubKey = pubKey
        self.privKey = privKey
    }
}
