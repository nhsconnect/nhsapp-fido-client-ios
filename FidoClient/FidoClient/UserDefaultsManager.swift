import Foundation
import LocalAuthentication

class UserDefaultsManager {
    static let userDefaults: UserDefaults = UserDefaults.standard
    static let KeyIDKey: String = "keyID"
    static let appIDKey: String = "appID"

    static func saveKeyID(_ keyID: String) {
        userDefaults.set(keyID, forKey: KeyIDKey)
    }
    
    static func getKeyID() throws -> String {
        if let keyID = UserDefaults.standard.string(forKey: KeyIDKey) {
            return keyID
        }
        throw FidoError.keyRetrievalError
    }
    
    static func deleteKeyID() {
        userDefaults.removeObject(forKey: KeyIDKey)
    }
    
    static func setAppID(_ appID: String?) {
        UserDefaults.standard.set(appID, forKey: appIDKey)
    }
}
