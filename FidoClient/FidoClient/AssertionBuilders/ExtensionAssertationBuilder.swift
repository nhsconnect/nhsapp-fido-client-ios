import Foundation
import LocalAuthentication

class ExtensionAssertionBuilder {
    let extensionId = "fido.uaf.uvm"
    
    func getExtensionData() -> [UInt8] {
        var buffer = [UInt8]()
        buffer.append(contentsOf: EncodingHelper.encodeInt(TagsEnum.TAG_EXTENSION_ID.rawValue))
        buffer.append(contentsOf: EncodingHelper.encodeInt(extensionId.lengthOfBytes(using: .utf8)))
        buffer.append(contentsOf: extensionId.utf8)
        
        let value = getUVMData()
        buffer.append(contentsOf: EncodingHelper.encodeInt(TagsEnum.TAG_EXTENSION_DATA.rawValue))
        buffer.append(contentsOf: EncodingHelper.encodeInt(value.count))
        buffer.append(contentsOf: value)
        return buffer
    }
    
    func getUVMData() -> [UInt8] {
        var buffer = [UInt8]()
        buffer.append(contentsOf: EncodingHelper.encodeLong(biometricType()))
        buffer.append(contentsOf: EncodingHelper.encodeInt(KeyProtection.KEY_PROTECTION_HARDWARE.rawValue
            + KeyProtection.KEY_PROTECTION_SECURE_ELEMENT.rawValue))
        buffer.append(contentsOf: EncodingHelper.encodeInt(MatcherProtection.MATCHER_PROTECTION_ON_CHIP.rawValue))
        return buffer
    }
    
    func biometricType() -> Int32 {
        let authContext = LAContext()
        if #available(iOS 11, *) {
            let _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            switch(authContext.biometryType) {
            case .none:
                return UserVerification.USER_VERIFY_PRESENCE.rawValue
            case .touchID:
                return UserVerification.USER_VERIFY_FINGERPRINT.rawValue + UserVerification.USER_VERIFY_PRESENCE.rawValue
            case .faceID:
                return UserVerification.USER_VERIFY_FACEPRINT.rawValue + UserVerification.USER_VERIFY_PRESENCE.rawValue
            }
        } else {
            return authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ?
                UserVerification.USER_VERIFY_FINGERPRINT.rawValue + UserVerification.USER_VERIFY_PRESENCE.rawValue :
                UserVerification.USER_VERIFY_PRESENCE.rawValue
        }
    }
}
